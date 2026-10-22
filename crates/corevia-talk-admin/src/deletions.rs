//! Thin `corevia-talk-admin deletions` adapter.

pub use corevia_talk_deletion::Command as DeletionsCommand;

/// Delegate to the shared durable deletion engine.
pub async fn run(command: DeletionsCommand) -> anyhow::Result<i32> {
    corevia_talk_deletion::run(command).await
}

#[cfg(test)]
mod tests {
    use clap::Parser;

    #[test]
    fn continuous_worker_command_is_not_exposed() {
        let command = crate::Cli::try_parse_from(["corevia-talk-admin", "deletions", "worker"]);
        assert!(command.is_err());
    }
}
