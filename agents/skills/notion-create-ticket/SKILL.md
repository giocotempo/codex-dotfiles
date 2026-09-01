---
name: notion-create-ticket
description: Create one Notion ticket at a request-supplied page or database URL, mapping any supplied purpose, as-is, to-be, and acceptance criteria. Use only when the user explicitly invokes $notion-create-ticket.
---

# Create one Notion ticket

1. Require a destination URL and enough details for a title in the current
   request; never reuse an earlier destination. Purpose, as-is, to-be, and
   acceptance criteria are optional unless the user requests a complete template.
2. Fetch the destination. If Notion is unavailable or the destination is
   inaccessible, stop and explain.
3. For a database or data source, inspect its schema, use the exact title
   property, and map supplied values only to clearly matching, type-compatible
   properties. Match labels by meaning, such as `As Is`, `As-Is`, or `Current
   State`. Ask which data source to use only when ambiguous. For a normal page,
   create a child page.
4. Preserve the user's facts. Do not invent status, priority, assignee, dates,
   labels, acceptance criteria, or conclusions. Omit unspecified properties so
   database defaults can apply.
5. Before adding a body, fetch `notion://docs/enhanced-markdown-spec` and follow
   it. Put unmapped supplied fields under `Purpose`, `As-Is`, `To-Be`, and
   `Acceptance Criteria`, in that order. Omit unsupplied or duplicated sections.
   Format multiple criteria as an unchecked checklist; mark items complete only
   when the user says they are satisfied. Include only relevant, non-secret context.
6. Create exactly one page; the invocation authorizes that write. Do not alter
   the destination's schema, views, templates, or parent pages.
7. If creation times out, check for success before retrying to avoid duplicates.
8. Report the ticket title, URL, destination, and populated properties.
