import React, { useState, useEffect } from "react";
import "./App.css";

function App() {
  const [messages, setMessages] = useState([]);
  const [name, setName] = useState("");
  const [text, setText] = useState("");

  const API_URL = "http://localhost:8080/messages";

  // Fetch all messages
  const fetchMessages = async () => {
    const res = await fetch(API_URL);
    const data = await res.json();
    setMessages(data);
  };

  useEffect(() => {
    fetchMessages();
  }, []);

  // Post a new message
  const addMessage = async () => {
    if (!name || !text) return;
    const res = await fetch(API_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ name, text }),
    });
    if (res.ok) {
      setName("");
      setText("");
      fetchMessages();
    }
  };

  // Delete a message
  const deleteMessage = async (id) => {
    const res = await fetch(`${API_URL}/${id}`, { method: "DELETE" });
    if (res.ok) fetchMessages();
  };

  return (
    <div className="App">
      <h1>Flood Message Board</h1>

      <div className="form">
        <input
          placeholder="Your Name"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
        <textarea
          placeholder="Your Message"
          value={text}
          onChange={(e) => setText(e.target.value)}
        />
        <button onClick={addMessage}>Send Message</button>
      </div>

      <div className="messages">
        {messages.map((msg) => (
          <div key={msg.id} className="message-card">
            <strong>{msg.name}</strong> ({msg.timestamp})
            <p>{msg.text}</p>
            <button onClick={() => deleteMessage(msg.id)}>Delete</button>
          </div>
        ))}
      </div>
    </div>
  );
}

export default App;
