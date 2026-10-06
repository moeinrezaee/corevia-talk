import { tl } from "@/shared/i18n/tl";
export const WORK_ITEM_TABLE_GRID_CLASS =
  "grid w-full grid-cols-[minmax(0,1fr)_5.5rem_4.5rem_3rem_5rem_1.5rem] items-center gap-x-3";

export function ProjectsWorkItemTableHeader({
  itemLabel,
  typeLabel,
}: {
  itemLabel: string;
  typeLabel: string;
}) {
  return (
    <thead className="sr-only">
      <tr>
        <th scope="col">{itemLabel}</th>
        <th scope="col">{typeLabel}</th>
        <th scope="col">{tl("Status")}</th>
        <th scope="col">{tl("Replies")}</th>
        <th scope="col">{tl("Updated")}</th>
        <th scope="col">{tl("Actions")}</th>
      </tr>
    </thead>
  );
}
