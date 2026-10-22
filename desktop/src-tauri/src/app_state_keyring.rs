/// Service name for the desktop OS keyring. Debug builds default to a distinct
/// service, while standalone worktree launches may request a scoped dev service.
fn dev_keyring_service(configured: Option<String>) -> String {
    configured
        .filter(|service| service.starts_with("corevia-talk-desktop-dev."))
        .unwrap_or_else(|| "corevia-talk-desktop-dev".to_string())
}

pub(crate) fn keyring_service() -> &'static str {
    if crate::build_identity::is_demo_build() {
        static DEMO_SERVICE: std::sync::OnceLock<String> = std::sync::OnceLock::new();
        DEMO_SERVICE
            .get_or_init(|| crate::build_identity::keyring_service().into_owned())
            .as_str()
    } else if cfg!(debug_assertions) {
        static DEV_SERVICE: std::sync::OnceLock<String> = std::sync::OnceLock::new();
        DEV_SERVICE
            .get_or_init(|| dev_keyring_service(std::env::var("COREVIA_TALK_DEV_KEYRING_SERVICE").ok()))
            .as_str()
    } else {
        "corevia-talk-desktop"
    }
}

pub(super) fn migration_marker_name(service: &str, default_name: &str) -> String {
    if service == "corevia-talk-desktop" || service == "corevia-talk-desktop-dev" {
        default_name.to_string()
    } else {
        format!("identity.{service}.migrated")
    }
}

#[cfg(test)]
mod tests {
    use super::{dev_keyring_service, migration_marker_name};

    #[test]
    fn standalone_scope_must_remain_under_dev_service() {
        assert_eq!(
            dev_keyring_service(Some("corevia-talk-desktop-dev.example".to_string())),
            "corevia-talk-desktop-dev.example"
        );
        assert_eq!(
            dev_keyring_service(Some("corevia-talk-desktop".to_string())),
            "corevia-talk-desktop-dev"
        );
    }

    #[test]
    fn standalone_scope_uses_its_own_migration_marker() {
        assert_eq!(
            migration_marker_name("corevia-talk-desktop", "identity.migrated"),
            "identity.migrated"
        );
        assert_eq!(
            migration_marker_name("corevia-talk-desktop-dev", "identity.migrated"),
            "identity.migrated"
        );
        assert_eq!(
            migration_marker_name("corevia-talk-desktop-dev.example", "identity.migrated"),
            "identity.corevia-talk-desktop-dev.example.migrated"
        );
    }
}
