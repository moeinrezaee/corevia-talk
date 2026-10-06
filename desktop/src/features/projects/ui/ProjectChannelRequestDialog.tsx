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
import { formatTtlDuration } from "@/features/channels/lib/ephemeralChannel";
import type { ProjectChannelRequest } from "@/features/projects/projectChannelRequest";
import { useProjectChannelRequests } from "@/features/projects/useProjectChannelRequests";
import { tl } from "@/shared/i18n/tl";

type RequestedChannel = ProjectChannelRequest["request"];

/** Details an owner reviews before approving an agent-requested project channel. */
export function ProjectChannelRequestDetails({
  request,
}: {
  request: RequestedChannel;
}) {
  return (
    <dl className="space-y-2 rounded-xl border border-border/60 bg-muted/25 p-3 text-sm">
      <div className="flex gap-3">
        <dt className="w-24 shrink-0 text-muted-foreground">{tl("Name")}</dt>
        <dd className="min-w-0 break-words text-foreground">#{request.name}</dd>
      </div>
      {request.description ? (
        <div className="flex gap-3">
          <dt className="w-24 shrink-0 text-muted-foreground">
            {tl("Description")}
          </dt>
          <dd className="min-w-0 break-words text-foreground">
            {request.description}
          </dd>
        </div>
      ) : null}
      <div className="flex gap-3">
        <dt className="w-24 shrink-0 text-muted-foreground">
          {tl("Visibility")}
        </dt>
        <dd className="text-foreground">{request.visibility}</dd>
      </div>
      {request.ttlSeconds ? (
        <div className="flex gap-3">
          <dt className="w-24 shrink-0 text-muted-foreground">
            {tl("Lifetime")}
          </dt>
          <dd className="min-w-0 break-words text-foreground">
            {tl("Temporary ·")} {formatTtlDuration(request.ttlSeconds)}
            {tl(". Cleans up automatically after that period of inactivity.")}
          </dd>
        </div>
      ) : null}
      {request.templateName ? (
        <div className="flex gap-3">
          <dt className="w-24 shrink-0 text-muted-foreground">
            {tl("Template")}
          </dt>
          <dd className="min-w-0 break-words text-foreground">
            {request.templateName}
          </dd>
        </div>
      ) : null}
    </dl>
  );
}

/** Global owner-review surface for project-channel requests from managed agents. */
export function ProjectChannelRequestDialog() {
  const management = useProjectChannelRequests();
  const request = management.request?.request;

  return (
    <AlertDialog
      onOpenChange={(open) => {
        if (!open) management.dismiss();
      }}
      open={request != null}
    >
      <AlertDialogContent data-testid="project-channel-request-dialog">
        <AlertDialogHeader>
          <AlertDialogTitle>{tl("Create project channel?")}</AlertDialogTitle>
          <AlertDialogDescription>
            {tl("Your agent requested a new channel in")}{" "}
            {management.project?.name ?? tl("this project")}
            {tl(". Review the details before creating it.")}
          </AlertDialogDescription>
        </AlertDialogHeader>
        {request ? <ProjectChannelRequestDetails request={request} /> : null}
        {management.error ? (
          <p className="text-sm text-destructive">{management.error}</p>
        ) : null}
        <AlertDialogFooter>
          <AlertDialogCancel disabled={management.isPending}>
            {tl("Cancel")}
          </AlertDialogCancel>
          <AlertDialogAction
            data-testid="project-channel-request-approve"
            disabled={management.isPending}
            onClick={(event) => {
              event.preventDefault();
              void management.approve();
            }}
          >
            {management.isPending ? tl("Creating…") : tl("Create channel")}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}
