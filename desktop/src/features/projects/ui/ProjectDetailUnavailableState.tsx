import { ArrowLeft, FolderGit2 } from "lucide-react";

import type { Project } from "@/features/projects/hooks";
import { Button } from "@/shared/ui/button";
import { UnavailableProjectRepositories } from "./UnavailableProjectRepositories";
import { tl } from "@/shared/i18n/tl";

type ProjectDetailUnavailableStateProps =
  | {
      kind: "load-error";
      onBack: () => void;
      onRetry: () => void;
    }
  | {
      kind: "not-found";
      onBack: () => void;
    }
  | {
      kind: "repositories-unavailable";
      project: Project;
    };

export function ProjectDetailUnavailableState(
  props: ProjectDetailUnavailableStateProps,
) {
  if (props.kind === "load-error") {
    return (
      <div className="flex flex-1 flex-col items-center justify-center gap-3 px-4 py-16 text-center">
        <FolderGit2 className="h-10 w-10 text-muted-foreground/40" />
        <p className="text-sm text-red-400">{tl("Failed to load project")}</p>
        <div className="flex items-center gap-2">
          <Button onClick={props.onRetry} size="sm" variant="outline">
            {tl("Retry")}
          </Button>
          <Button onClick={props.onBack} size="sm" variant="ghost">
            <ArrowLeft className="me-1.5 h-4 w-4" />
            {tl("Back to Projects")}
          </Button>
        </div>
      </div>
    );
  }

  if (props.kind === "not-found") {
    return (
      <div className="flex flex-1 flex-col items-center justify-center gap-3 px-4 py-16 text-center">
        <FolderGit2 className="h-10 w-10 text-muted-foreground/40" />
        <p className="text-sm text-muted-foreground">
          {tl("This project could not be found.")}
        </p>
        <Button onClick={props.onBack} size="sm" variant="outline">
          <ArrowLeft className="me-1.5 h-4 w-4" />
          {tl("Back to Projects")}
        </Button>
      </div>
    );
  }

  return (
    <div className="flex flex-1 flex-col items-center justify-center gap-3 px-4 py-16 text-center">
      <FolderGit2 className="h-10 w-10 text-muted-foreground/40" />
      <p className="text-sm font-medium text-foreground">
        {props.project.name}
      </p>
      <p className="text-sm text-muted-foreground">
        {tl("This project does not have any available repositories yet.")}
      </p>
      <UnavailableProjectRepositories project={props.project} />
    </div>
  );
}
