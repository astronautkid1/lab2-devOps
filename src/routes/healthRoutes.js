// src/routes/healthRoutes.js
const express = require("express");
const router = express.Router();

router.get("/live", (req, res) => {
  res.status(200).json({ status: "ok" });
});

router.get("/ready", async (req, res) => {
  try {
    // Test database connection
    await require("../models/book").sequelize.authenticate();
    res.status(200).json({ status: "ok" });
  } catch (error) {
    res.status(500).json({ status: "error", message: error.message });
  }
});

module.exports = router;