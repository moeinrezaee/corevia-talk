import { X } from "lucide-react";

import { Button } from "@/shared/ui/button";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/shared/ui/dialog";
import { Skeleton } from "@/shared/ui/skeleton";
import { tl } from "@/shared/i18n/tl";

type WorkflowUnavailableDialogProps = {
  loading: boolean;
  onOpenChange: (open: boolean) => void;
  onRetry: () => void;
  open: boolean;
};

export function WorkflowUnavailableDialog({
  loading,
  onOpenChange,
  onRetry,
  open,
}: WorkflowUnavailableDialogProps) {
  return (
    <Dialog onOpenChange={onOpenChange} open={open}>
      <DialogContent className="sm:max-w-lg" showCloseButton={false}>
        <DialogHeader>
          <DialogTitle>
            {loading ? tl("Loading workflow…") : tl("Workflow unavailable")}
          </DialogTitle>
          <DialogDescription>
            {loading
              ? tl("Resolving workflow details.")
              : tl(
                  "This workflow could not be loaded. It may no longer be available to you.",
                )}
          </DialogDescription>
        </DialogHeader>
        {loading ? (
          <div
            aria-label={tl("Loading workflow")}
            className="space-y-3"
            role="status"
          >
            <Skeleton className="h-5 w-48" />
            <Skeleton className="h-24 w-full rounded-xl" />
          </div>
        ) : (
          <DialogFooter>
            <DialogClose asChild>
              <Button type="button" variant="outline">
                <X className="h-4 w-4" />
                {tl("Close")}
              </Button>
            </DialogClose>
            <Button onClick={onRetry} type="button">
              {tl("Retry")}
            </Button>
          </DialogFooter>
        )}
      </DialogContent>
    </Dialog>
  );
}
