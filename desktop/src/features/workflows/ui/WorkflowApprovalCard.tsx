import type { WorkflowApproval } from "@/shared/api/types";
import { tl } from "@/shared/i18n/tl";

type WorkflowApprovalCardProps = {
  approval: WorkflowApproval;
};

export function WorkflowApprovalCard({ approval }: WorkflowApprovalCardProps) {
  const isExpired = new Date(approval.expiresAt) < new Date();

  if (approval.status !== "pending" || isExpired) {
    return null;
  }

  return (
    <div
      className="rounded-lg border border-amber-500/30 bg-amber-500/5 p-3"
      data-testid="workflow-approval-card"
    >
      <p className="mb-2 text-sm font-medium">{tl("Approval Required")}</p>
      <p className="mb-2 text-xs text-muted-foreground">
        {tl("Approver:")} {approval.approverSpec}
      </p>
      <p className="mb-2 text-xs text-muted-foreground">
        {tl("Expires:")} {new Date(approval.expiresAt).toLocaleString()}
      </p>
      <p className="text-xs text-muted-foreground" role="status">
        {tl("Approval actions are not yet available in Desktop.")}
      </p>
    </div>
  );
}
