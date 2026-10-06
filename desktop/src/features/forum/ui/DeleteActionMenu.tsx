import { MoreHorizontal, Trash2 } from "lucide-react";
import * as React from "react";

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/shared/ui/dropdown-menu";

import { DeleteConfirmDialog } from "./DeleteConfirmDialog";
import { tl } from "@/shared/i18n/tl";

type DeleteActionMenuProps = {
  label: string;
  onConfirm: () => void;
  iconSize?: "sm" | "md";
};

export function DeleteActionMenu({ label, onConfirm }: DeleteActionMenuProps) {
  const [isOpen, setIsOpen] = React.useState(false);
  const iconClass = "h-4 w-4";

  return (
    <div className="ms-auto opacity-0 transition-opacity group-hover:opacity-100">
      <DropdownMenu modal={false}>
        <DropdownMenuTrigger asChild>
          <button
            className="rounded-md p-1 text-muted-foreground hover:bg-accent hover:text-foreground"
            tabIndex={-1}
            type="button"
          >
            <MoreHorizontal className={iconClass} />
          </button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem
            className="text-destructive focus:text-destructive"
            onClick={() => setIsOpen(true)}
          >
            <Trash2 className="me-2 h-4 w-4" />
            {tl("Delete")} {label}
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
      <DeleteConfirmDialog
        label={label}
        onConfirm={onConfirm}
        onOpenChange={setIsOpen}
        open={isOpen}
      />
    </div>
  );
}
