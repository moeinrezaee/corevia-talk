import { Eye, EyeOff } from "lucide-react";
import * as React from "react";

import { CopyButton } from "@/features/agents/ui/CopyButton";
import { Button } from "@/shared/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/shared/ui/dialog";
import { tl, tlt } from "@/shared/i18n/tl";

type WorkflowWebhookSecretDialogProps = {
  onContinue: () => void;
  open: boolean;
  relayHttpUrl: string | null;
  relayUrlError: string | null;
  webhookSecret: string;
  workflowId: string;
};

export function WorkflowWebhookSecretDialog({
  onContinue,
  open,
  relayHttpUrl,
  relayUrlError,
  webhookSecret,
  workflowId,
}: WorkflowWebhookSecretDialogProps) {
  const [revealed, setRevealed] = React.useState(false);
  const webhookUrl = relayHttpUrl
    ? `${relayHttpUrl}/hooks/${workflowId}`
    : null;

  return (
    <Dialog onOpenChange={(nextOpen) => !nextOpen && onContinue()} open={open}>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle>{tl("Webhook ready")}</DialogTitle>
          <DialogDescription>
            {tl(
              "This private secret is shown once and cannot be recovered. Copy and store it before continuing.",
            )}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4">
          <div className="space-y-1.5">
            <p className="text-xs font-medium text-muted-foreground">
              {tl("Webhook URL")}
            </p>
            {webhookUrl ? (
              <>
                <pre className="overflow-x-auto rounded-md bg-muted/50 p-3 font-mono text-xs">
                  {webhookUrl}
                </pre>
                <CopyButton label={tl("Copy URL")} value={webhookUrl} />
              </>
            ) : (
              <p
                className={
                  relayUrlError
                    ? "rounded-md border border-destructive/30 bg-destructive/10 p-3 text-sm text-destructive"
                    : "rounded-md bg-muted/50 p-3 text-sm text-muted-foreground"
                }
              >
                {relayUrlError
                  ? tlt(
                      "The workflow was saved, but its webhook URL could not be loaded: {0}",
                      [relayUrlError],
                    )
                  : tl("Loading webhook URL…")}
              </p>
            )}
          </div>

          <div className="space-y-1.5">
            <p className="text-xs font-medium text-muted-foreground">
              {tl("`X-Webhook-Secret`")}
            </p>
            <div className="flex items-center gap-2 rounded-md bg-muted/50 p-3">
              <code className="min-w-0 flex-1 overflow-x-auto font-mono text-xs">
                {revealed ? webhookSecret : "•".repeat(24)}
              </code>
              <Button
                aria-label={
                  revealed
                    ? tl("Hide webhook secret")
                    : tl("Reveal webhook secret")
                }
                onClick={() => setRevealed((value) => !value)}
                size="icon-xs"
                type="button"
                variant="ghost"
              >
                {revealed ? <EyeOff /> : <Eye />}
              </Button>
            </div>
            <CopyButton label={tl("Copy Secret")} value={webhookSecret} />
          </div>
        </div>
        <DialogFooter>
          <Button onClick={onContinue} type="button">
            {tl("Continue")}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
