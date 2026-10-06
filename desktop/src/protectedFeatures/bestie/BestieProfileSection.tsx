import * as React from "react";
import { Star } from "lucide-react";
import { toast } from "sonner";

import { ProfileAgentActionRow } from "@/features/profile/ui/UserProfileAgentManagementRows";
import type { ManagedAgent } from "@/shared/api/types";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/shared/ui/alert-dialog";
import { useBestie } from "./useBestie";
import { tl, tlt } from "@/shared/i18n/tl";

export function BestieProfileAction({ agent }: { agent: ManagedAgent }) {
  const bestie = useBestie();
  const [confirmOpen, setConfirmOpen] = React.useState(false);
  if (agent.backend.type !== "local") return null;

  const isBestie =
    bestie.assignment?.agentPubkey.toLowerCase() === agent.pubkey.toLowerCase();
  const isPending = bestie.isAssigning;
  const handleClick = () => {
    if (!isBestie) {
      setConfirmOpen(true);
      return;
    }
    void bestie.clearAssignment().catch((error) => {
      toast.error(
        error instanceof Error ? error.message : "Couldn’t update Bestie",
      );
    });
  };

  return (
    <>
      <ProfileAgentActionRow
        disabled={bestie.isLoading || isPending}
        icon={Star}
        iconClassName={
          isBestie ? "h-4 w-4 shrink-0 fill-current text-foreground" : undefined
        }
        label={isBestie ? tl("Remove Bestie") : tl("Make Bestie")}
        onClick={handleClick}
        testId="user-profile-bestie-action"
      />
      <AlertDialog onOpenChange={setConfirmOpen} open={confirmOpen}>
        <AlertDialogContent data-testid="bestie-confirm-dialog">
          <AlertDialogHeader>
            <AlertDialogTitle>
              {tl("Make")} {agent.name} {tl("your Bestie?")}
            </AlertDialogTitle>
            <AlertDialogDescription>
              {bestie.assignedAgent && !isBestie
                ? tlt(
                    "{0} will replace {1} in the floating shortcut and message actions.",
                    [agent.name, bestie.assignedAgent.name],
                  )
                : tlt(
                    "{0} will appear in the floating shortcut and message actions.",
                    [agent.name],
                  )}
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={isPending}>
              {tl("Cancel")}
            </AlertDialogCancel>
            <AlertDialogAction
              disabled={isPending}
              onClick={(event) => {
                event.preventDefault();
                void bestie
                  .assignAgent(agent)
                  .then(() => setConfirmOpen(false))
                  .catch((error) => {
                    toast.error(
                      error instanceof Error
                        ? error.message
                        : "Couldn’t update Bestie",
                    );
                  });
              }}
            >
              {isPending ? tl("Saving…") : tl("Make Bestie")}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}
