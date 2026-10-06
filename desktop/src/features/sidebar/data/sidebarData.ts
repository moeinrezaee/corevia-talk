import { tl } from "@/shared/i18n/tl";
export type Channel = {
  name: string;
  unread?: number;
  active?: boolean;
  variant: "public" | "private" | "direct";
};

export type ChannelSection = {
  title: string;
  items: Channel[];
};

export const sidebarSections: ChannelSection[] = [
  {
    title: tl("Pinned"),
    items: [
      {
        name: "general",
        unread: 1,
        variant: "public",
      },
      {
        name: "product-launch",
        unread: 3,
        active: true,
        variant: "public",
      },
    ],
  },
  {
    title: tl("Channels"),
    items: [
      {
        name: "engineering",
        variant: "public",
      },
      {
        name: "planning",
        variant: "private",
      },
    ],
  },
  {
    title: tl("Direct Messages"),
    items: [
      {
        name: "Avery",
        variant: "direct",
      },
      {
        name: "Noa",
        variant: "direct",
      },
    ],
  },
];
