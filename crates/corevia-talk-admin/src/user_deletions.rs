//! Thin `corevia-talk-admin user-deletions` adapter.

pub use corevia_talk_deletion::user::Command as UserDeletionsCommand;

/// Delegate request intake to the shared deletion crate.
pub async fn run(command: UserDeletionsCommand) -> anyhow::Result<i32> {
    corevia_talk_deletion::user::run(command).await
}

#[cfg(test)]
mod tests {
    use clap::Parser;

    #[test]
    fn user_intake_commands_are_registered_without_execution() {
        for args in [
            vec![
                "corevia-talk-admin",
                "user-deletions",
                "submit",
                "--target",
                "demo:alice",
                "--requested-by",
                "operator-a",
            ],
            vec!["corevia-talk-admin", "user-deletions", "list"],
            vec![
                "corevia-talk-admin",
                "user-deletions",
                "inspect",
                "00000000-0000-0000-0000-000000000001",
            ],
        ] {
            assert!(crate::Cli::try_parse_from(args).is_ok());
        }
        for command in ["inventory", "approve", "run", "drain", "worker"] {
            assert!(crate::Cli::try_parse_from(["corevia-talk-admin", "user-deletions", command]).is_err());
        }
    }
}
