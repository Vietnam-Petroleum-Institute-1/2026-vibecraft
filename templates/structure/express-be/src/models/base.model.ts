// Domain shape shared by every persisted model — see AGENTS.md "Architecture
// Rules": models are data definitions only, no business logic methods.
// Repositories map Prisma's generated types onto shapes like this one so the
// service layer never depends on Prisma types directly.
export interface BaseModel {
  id: string;
  createdAt: Date;
  updatedAt: Date;
}
