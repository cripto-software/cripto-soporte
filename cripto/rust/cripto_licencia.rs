// ============================================================
// 📁 RUTA : cripto/rust/cripto_licencia.rs
//          (al compilar, aplicar_marca.py lo copia a src/cripto_licencia.rs)
// 📌 ARCHIVO: cripto_licencia.rs
// 📝 RESUMEN: «Enchufe» mínimo de CRIPTO Soporte con el servidor de
//             licencias de PCG SAS (api.criptosoftware.com).
//             • Programa del técnico: antes de cada conexión pide un PASE
//               de un solo uso con la credencial de su licencia y lo envía
//               junto con la solicitud de conexión. Sin licencia no pide
//               nada (la versión gratuita funciona igual entre PC).
//             • App del celular (Android): al recibir una conexión pregunta
//               al servidor si el pase es válido. Si no lo es, si no hay
//               pase o si no hay internet, RECHAZA la conexión antes de
//               mostrar nada. Al terminar, avisa el fin de la sesión.
//             Toda la lógica de licencias vive en el servidor de PCG SAS;
//             aquí solo se pregunta y se obedece. Solo HTTPS con
//             certificado válido. Nunca se escribe en el log la
//             credencial ni el pase.
// 👤 AUTOR   : Téc. Sup. Pablo Quichimbo — PCG SAS
// ©  Propiedad intelectual de Pablo Quichimbo. Todos los derechos reservados.
//    (Este archivo forma parte de un trabajo derivado de RustDesk,
//     distribuido bajo la licencia AGPL-3.0.)
// ------------------------------------------------------------
// Historial
//   v1.0  26/11/2026  Versión inicial (pases de un solo uso).
// ============================================================

use hbb_common::{
    config::{Config, LocalConfig},
    log,
    password_security::{decrypt_str_or_original, encrypt_str_or_original},
    tokio::time::timeout,
};
use serde_json::{json, Value};
use std::{
    collections::HashMap,
    sync::Mutex,
    time::{Duration, Instant},
};

/// Servidor de licencias de PCG SAS.
const API: &str = "https://api.criptosoftware.com/api/soporte/licencia";
/// Opción local donde el programa del técnico guarda su credencial (cifrada).
pub const OPCION_CREDENCIAL: &str = "cripto-credencial";
/// Mensaje que recibe un técnico sin autorización al intentar entrar a un celular.
#[allow(dead_code)]
pub const MENSAJE_BLOQUEO: &str = "Este técnico no está autorizado por CRIPTO. \
Si necesita ayuda, escríbanos al WhatsApp 098 566 6807.";

const ESPERA_MAXIMA: Duration = Duration::from_secs(8);
/// Un pase ya validado en ESTE celular se acepta de nuevo durante este tiempo
/// (reintentos de la misma conexión) sin volver a consultar al servidor.
const VIGENCIA_LOCAL: Duration = Duration::from_secs(600);

lazy_static::lazy_static! {
    static ref VALIDADOS: Mutex<HashMap<String, Instant>> = Mutex::new(HashMap::new());
}

/// ID sin el sufijo «@servidor».
fn id_puro(id: &str) -> String {
    id.split('@').next().unwrap_or(id).trim().replace(' ', "")
}

/// Credencial del técnico. Si la pantalla de activación la dejó en texto
/// plano, aquí se cifra en la configuración local.
fn credencial() -> String {
    let guardada = LocalConfig::get_option(OPCION_CREDENCIAL);
    if guardada.is_empty() {
        return guardada;
    }
    let (plano, estaba_cifrada, _) = decrypt_str_or_original(&guardada, "00");
    if !estaba_cifrada {
        LocalConfig::set_option(
            OPCION_CREDENCIAL.to_owned(),
            encrypt_str_or_original(&plano, "00", 128),
        );
    }
    plano
}

/// POST JSON al servidor de licencias. Devuelve la respuesta solo si es válida.
async fn enviar(ruta: &str, cuerpo: Value, credencial: Option<&str>) -> Option<Value> {
    let url = format!("{API}/{ruta}");
    let cliente = match crate::hbbs_http::create_http_client_async_with_url_strict(&url).await {
        Ok(c) => c,
        Err(e) => {
            log::warn!("[CRIPTO] Licencia: no se pudo preparar la conexión ({ruta}): {e}");
            return None;
        }
    };
    let mut peticion = cliente.post(&url).json(&cuerpo);
    if let Some(c) = credencial {
        peticion = peticion.header("X-Cripto-Credencial", c);
    }
    let respuesta = match timeout(ESPERA_MAXIMA, peticion.send()).await {
        Ok(Ok(r)) => r,
        Ok(Err(e)) => {
            log::warn!("[CRIPTO] Licencia: sin respuesta del servidor ({ruta}): {e}");
            return None;
        }
        Err(_) => {
            log::warn!("[CRIPTO] Licencia: el servidor tardó demasiado ({ruta})");
            return None;
        }
    };
    let estado = respuesta.status().as_u16();
    match respuesta.json::<Value>().await {
        Ok(v) => {
            if estado >= 400 {
                log::info!(
                    "[CRIPTO] Licencia: {ruta} rechazado ({estado}): {}",
                    v.get("message").and_then(|m| m.as_str()).unwrap_or("")
                );
            }
            Some(v)
        }
        Err(e) => {
            log::warn!("[CRIPTO] Licencia: respuesta ilegible ({ruta}, {estado}): {e}");
            None
        }
    }
}

/// Programa del técnico: pide un pase de un solo uso para conectarse a
/// `destino_id`. Sin licencia activada devuelve una cadena vacía.
#[allow(dead_code)]
pub async fn pedir_pase(destino_id: &str) -> String {
    let cred = credencial();
    if cred.is_empty() {
        return String::new();
    }
    let cuerpo = json!({
        "rustdeskId": id_puro(&Config::get_id()),
        "destinoId": id_puro(destino_id),
        "destino": "CELULAR"
    });
    let Some(r) = enviar("pase", cuerpo, Some(&cred)).await else {
        return String::new();
    };
    match r.pointer("/data/pase").and_then(|p| p.as_str()) {
        Some(p) if !p.is_empty() => {
            log::info!("[CRIPTO] Licencia: pase obtenido para {}", id_puro(destino_id));
            p.to_owned()
        }
        _ => String::new(),
    }
}

/// App del celular: ¿el técnico `tecnico_id` trae un pase válido para ESTE
/// equipo? Ante cualquier duda (sin pase, sin internet, error) responde NO.
#[allow(dead_code)]
pub async fn validar_pase(tecnico_id: &str, pase: &str) -> bool {
    let pase = pase.trim().to_uppercase();
    if !pase.is_empty() {
        let mut validados = VALIDADOS.lock().unwrap();
        validados.retain(|_, t| t.elapsed() < VIGENCIA_LOCAL);
        if validados.contains_key(&pase) {
            return true;
        }
    }
    let tecnico = id_puro(tecnico_id);
    let cuerpo = json!({
        "tecnicoId": tecnico,
        "destinoId": id_puro(&Config::get_id()),
        "pase": pase
    });
    let permitido = enviar("validar", cuerpo, None)
        .await
        .and_then(|r| r.pointer("/data/permitido").and_then(|p| p.as_bool()))
        .unwrap_or(false);
    if permitido {
        VALIDADOS.lock().unwrap().insert(pase, Instant::now());
        log::info!("[CRIPTO] Licencia: conexión AUTORIZADA del técnico {tecnico}");
    } else {
        log::warn!("[CRIPTO] Licencia: conexión RECHAZADA del técnico {tecnico}");
    }
    permitido
}

/// App del celular: avisa que terminó la sesión (en segundo plano).
#[allow(dead_code)]
pub fn avisar_fin_sesion(tecnico_id: String) {
    let tecnico = id_puro(&tecnico_id);
    if tecnico.is_empty() {
        return;
    }
    hbb_common::tokio::spawn(async move {
        let cuerpo = json!({
            "tecnicoId": tecnico,
            "destinoId": id_puro(&Config::get_id())
        });
        let _ = enviar("sesion-fin", cuerpo, None).await;
    });
}
