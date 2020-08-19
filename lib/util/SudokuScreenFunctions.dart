int getIndex(int row, int col, int rowLength) {
  return row * rowLength + col % rowLength;
}
