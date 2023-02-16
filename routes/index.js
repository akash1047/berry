const express = require("express");
const router = express.Router();

router.get("/", (req, res) => {
  // res.send("yolo");
  res.render("index");
});

module.exports = router;
