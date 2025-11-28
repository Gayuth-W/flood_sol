import React, { useState, useEffect } from "react";
import axios from "axios";
import "./App.css";

function App() {
  const [messages, setMessages] = useState([]);
  const [name, setName] = useState("");
  const [text, setText] = useState("");
  const [loading, setLoading] = useState(false);

  const API_URL = "http://localhost:8080/floodboard";

  const fetchMessages = async () => {
    try {
      const res = await axios.get(`${API_URL}/messages`);
      setMessages(res.data);
    } catch (err) {
      console.error(err);
    }
  };

  const postMessage = async (e) => {
    e.preventDefault();
    if (!text) return;

    setLoading(true);
    try {
      const payload = { name: name || "Anonymous", text };
      await axios.post(`${API_URL}/message`, payload);
      setName("");
      setText("");
      fetchMessages();
    } catch (err) {
      console.error(err);
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchMessages();
  }, []);

  return (
    <div className="App">
      <h1>🌊 Floodboard</h1>

      <form onSubmit={postMessage} className="message-form">
        <input
          type="text"
          placeholder="Your name (optional)"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
        <textarea
          placeholder="Your message"
          value={text}
          onChange={(e) => setText(e.target.value)}
        />
        <button type="submit" disabled={loading}>
          {loading ? "Posting..." : "Post Message"}
        </button>
      </form>

      <div className="messages">
        {messages.length === 0 ? (
          <p>No messages yet. Be the first!</p>
        ) : (
          messages.map((msg) => (
            <div key={msg.id} className="message-card">
              <p className="message-text">{msg.text}</p>
              <p className="message-meta">
                — {msg.name || "Anonymous"} |{" "}
                {new Date(msg.timestamp).toLocaleString()}
              </p>
            </div>
          ))
        )}
      </div>
    </div>
  );
}

export default App;
