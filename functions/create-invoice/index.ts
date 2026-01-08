import { serve } from "https://deno.land/std@0.201.0/http/server.ts";
import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables');
}

serve(async (req: Request) => {
  try {
    const body = await req.json();
    const {
      id,
      client,
      client_name,
      clientName,
      client_email,
      clientEmail,
      contact_id,
      contactId,
      amount,
      due_date,
      dueDate,
      project_id,
      projectId,
      quote_id,
      quoteId,
      owner_id,
      ownerId,
      status,
      payment_method,
      paymentMethod,
      issued_at,
      issuedAt,
    } = body;
    // owner_id is required because `finance_invoices.owner_id` is NOT NULL
    const ownerIdValue = owner_id ?? ownerId ?? null;
    const clientNameValue =
      (client_name ?? clientName ?? client ?? null) as string | null;
    const projectIdValue = (project_id ?? projectId ?? null) as string | null;
    const quoteIdValue = (quote_id ?? quoteId ?? null) as string | null;
    const dueDateValue = (due_date ?? dueDate ?? null) as string | null;
    const issuedAtValue = (issued_at ?? issuedAt ?? null) as string | null;
    const contactIdValue = (contact_id ?? contactId ?? null) as string | null;
    const clientEmailValue = (client_email ?? clientEmail ?? null) as
      | string
      | null;
    const invoiceId = (id ?? `inv${Date.now()}`) as string;

    if (!clientNameValue || amount == null || !ownerIdValue) {
      return new Response(
        JSON.stringify({
          error:
            'Missing required fields: client_name (or client), amount, owner_id',
        }),
        { status: 400 },
      );
    }

    const supabase = createClient(SUPABASE_URL ?? '', SUPABASE_SERVICE_ROLE_KEY ?? '');

    const payload: Record<string, unknown> = {
      id: invoiceId,
      client_name: clientNameValue,
      client_email: clientEmailValue,
      contact_id: contactIdValue,
      amount,
      owner_id: ownerIdValue,
      issued_at: issuedAtValue ?? new Date().toISOString(),
      due_date: dueDateValue,
      project_id: projectIdValue,
      quote_id: quoteIdValue,
      status: status ?? 'unpaid',
      payment_method: payment_method ?? paymentMethod ?? null,
    };

    const { data, error } = await supabase
      .from('finance_invoices')
      .insert(payload)
      .select()
      .single();

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), { status: 500 });
    }

    return new Response(JSON.stringify(data), {
      status: 201,
      headers: { 'content-type': 'application/json' },
    });
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : String(err);
    return new Response(JSON.stringify({ error: message }), { status: 500 });
  }
});
