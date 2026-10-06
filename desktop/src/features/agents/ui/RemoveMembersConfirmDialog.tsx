import {
  AlertDialog,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/shared/ui/alert-dialog";
import { Button } from "@/shared/ui/button";
import { tl } from "@/shared/i18n/tl";

type RemoveMembersConfirmDialogProps = {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  isPending: boolean;
  memberNames: string[];
  onKeepAgents: () => void;
  onRemoveAgents: () => void;
};

export function RemoveMembersConfirmDialog({
  open,
  onOpenChange,
  isPending,
  memberNames,
  onKeepAgents,
  onRemoveAgents,
}: RemoveMembersConfirmDialogProps) {
  const count = memberNames.length;
  const plural = count !== 1;

  return (
    <AlertDialog onOpenChange={onOpenChange} open={open}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>
            {tl("Remove")} {count} {tl("member")}
            {plural ? "s" : ""}?
          </AlertDialogTitle>
          <AlertDialogDescription>
            {memberNames.join(", ")}{" "}
            {tl(
              "will be removed from this team. Do you also want to remove the",
            )}{" "}
            {plural ? "agents" : "agent"} {tl("completely?")}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <Button
            onClick={() => onOpenChange(false)}
            size="sm"
            type="button"
            variant="outline"
          >
            {tl("Cancel")}
          </Button>
          <Button
            disabled={isPending}
            onClick={onKeepAgents}
            size="sm"
            type="button"
            variant="outline"
          >
            {tl("Keep")} {plural ? "agents" : "agent"}
          </Button>
          <Button
            disabled={isPending}
            onClick={onRemoveAgents}
            size="sm"
            type="button"
            variant="destructive"
          >
            {tl("Remove")} {plural ? "agents" : "agent"}
          </Button>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}
