---
name: notion-create-ticket
description: Create one Notion ticket at a page or database URL supplied in the current request. Use only when the user explicitly invokes $notion-create-ticket.
---

# Create one Notion ticket

1. Require a destination URL and enough details for a title in the current
   request. Ask only for missing required information; never reuse an earlier
   destination.
2. Fetch the destination. If Notion is unavailable or the destination is
   inaccessible, stop and explain.
3. For a database or data source, inspect its schema, use the exact title
   property, and map only supplied values to supported properties. Ask which
   data source to use only when the choice is ambiguous. For a normal page,
   create a child page.
4. Preserve the user's facts. Do not invent status, priority, assignee, dates,
   labels, acceptance criteria, or conclusions. Omit unspecified properties so
   database defaults can apply.
5. Before adding a body, fetch `notion://docs/enhanced-markdown-spec` and follow
   it. Include only relevant context; never include secrets.
6. Create exactly one page. The explicit invocation authorizes that write, but
   honor host approval prompts and ask when a material choice remains unclear.
   Do not alter the destination's schema, views, templates, or parent pages.
7. If creation times out, check for success before retrying to avoid duplicates.
8. Report the ticket title, URL, destination, and populated properties.
