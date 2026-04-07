import express from "express";
import cors from "cors";

const app = express();
app.use(cors());
app.use(express.json({ limit: "1mb" }));

const PORT = process.env.PORT ? Number(process.env.PORT) : 8787;
const OPENROUTER_API_KEY = (process.env.OPENROUTER_API_KEY ?? "").trim();
const OPENROUTER_MODEL = (process.env.OPENROUTER_MODEL ?? "openai/gpt-4o-mini").trim();
const APP_URL = (process.env.APP_URL ?? "").trim(); // optional: for OpenRouter ranking
const APP_NAME = (process.env.APP_NAME ?? "StudyMate AI").trim(); // optional

app.get("/health", (_req, res) => {
  res.json({ ok: true });
});

app.post("/chat", async (req, res) => {
  try {
    const { message, history } = req.body ?? {};
    if (typeof message !== "string" || !message.trim()) {
      return res.status(400).json({
        error: { message: "Missing 'message' string" },
      });
    }

    const safeHistory = Array.isArray(history) ? history : [];

    if (!OPENROUTER_API_KEY) {
      return res.status(400).json({
        error: { message: "Missing OPENROUTER_API_KEY in server environment" },
      });
    }

    const system =
      "Ты StudyMate AI — дружелюбный помощник студенту. Отвечай по-русски, коротко, ясно и по делу. " +
      "Если вопрос про математику — дай простое объяснение и мини-пример.";

    const messages = [
      { role: "system", content: system },
      ...safeHistory
        .filter(
          (m) =>
            m &&
            (m.role === "user" || m.role === "assistant") &&
            typeof m.content === "string"
        )
        .map((m) => ({ role: m.role, content: m.content })),
      { role: "user", content: message.trim() },
    ];

    const headers = {
      "Content-Type": "application/json",
      Authorization: `Bearer ${OPENROUTER_API_KEY}`,
    };
    if (APP_URL) headers["HTTP-Referer"] = APP_URL;
    if (APP_NAME) headers["X-Title"] = APP_NAME;

    const r = await fetch("https://openrouter.ai/api/v1/chat/completions", {
      method: "POST",
      headers,
      body: JSON.stringify({
        model: OPENROUTER_MODEL,
        messages,
        temperature: 0.6,
      }),
    });

    const text = await r.text();
    let data;
    try {
      data = JSON.parse(text);
    } catch {
      data = null;
    }

    if (!r.ok) {
      const msg =
        data?.error?.message ??
        data?.message ??
        `OpenRouter error ${r.status}: ${text?.slice(0, 200) ?? ""}`;
      return res.status(502).json({ error: { message: msg } });
    }

    const reply = data?.choices?.[0]?.message?.content;
    if (typeof reply !== "string" || !reply.trim()) {
      return res.status(502).json({ error: { message: "Empty AI reply" } });
    }

    return res.json({ reply: reply.trim() });
  } catch (e) {
    return res.status(500).json({
      error: { message: e?.message ? String(e.message) : "Server error" },
    });
  }
});

app.listen(PORT, () => {
  console.log(`[studymate-ai-proxy] listening on http://localhost:${PORT}`);
});

