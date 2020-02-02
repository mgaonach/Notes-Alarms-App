String formatAndCut(String string, int limit) {
  string = string.replaceAll("\n", " ").trim();
  if (string.length > limit) {
    return string.substring(0, limit - 4) + "...";
  }
  return string;
}