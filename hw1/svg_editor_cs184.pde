

ArrayList<Shape> shapes;
int selected;
int selectedVertex;
String[] data;
boolean keyIsPressed = false;
int r, g, b;
int selectedSlider;
color copiedColor;
void setup() {
  size(1000, 1000);
  background(255,0,0);
  shapes = new ArrayList<Shape>();
  selected = -1;
  selectedSlider = -1;
  selectedVertex = -1;
  data = loadStrings("data.txt");
  for (String line : data) {
    System.out.println(line);
    String[] words = line.split(" ");
    color c = unhex(words[0]);
    System.out.println(c);
    ArrayList<Point> points = new ArrayList<Point>();
    for (int i = 1; i < words.length; i += 2) {
      System.out.println(words[i] + " " + words[i+1]);
      Point p = new Point(Integer.parseInt(words[i]), Integer.parseInt(words[i+1]));  
      points.add(p);
      //System.out.println(p);
    }
    shapes.add(new Shape(c, points));
  }
  
}
class Point {
  int x, y;
  Point() {
     x = 0;
     y = 0;
  }
  Point(int x, int y) {
    this.x = x;
    this.y = y;
  }
  Point(float x, float y) {
    this.x = (int) x;
    this.y = (int) y;
  }
  String toString() {
    return x + " " + y;  
  }
}
class LineIntersect {
  LineIntersect() {}
  boolean isBetween(int a, int b, int c) {
    return Math.min(a, c) <= b && b <= Math.max(a, c);
  }
  boolean check(Point start1, Point end1, Point start2, Point end2) {
    int x1 = start1.x, y1 = start1.y;
    int x2 = end1.x, y2 = end1.y;
    int x3 = start2.x, y3 = start2.y;
    int x4 = end2.x, y4 = end2.y;
    int det = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (det == 0) return false; 
    int intersectionX = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / det;
    int intersectionY = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / det;
    return isBetween(x1, intersectionX, x2) && isBetween(y1, intersectionY, y2) && isBetween(x3, intersectionX, x4) && isBetween(y3, intersectionY, y4);
  }
}
class Shape {
  ArrayList<Point> points;
  color c;
  Shape() {
    points = new ArrayList();
    points.add(new Point(100, 100));
    points.add(new Point(700, 100));
    //points.add(new Point(700, 700));
    points.add(new Point(100, 700));
    c = #FF0000;
  }
  Shape(color c) {
    points = new ArrayList();
    points.add(new Point(100, 100));
    points.add(new Point(700, 100));
    //points.add(new Point(700, 700));
    points.add(new Point(100, 700));
    this.c = c;
  }
  Shape(color c, ArrayList<Point> points) {
    this.c = c;
    this.points = points;
  }
  void draw() {
    if (mouseInside()) {
      strokeWeight(1);
      stroke(0,0,0);
    } else {
      noStroke();
    }
    
    fill(c);
    beginShape();
    for (Point p : points) {
      vertex(p.x+100, p.y+100);
    }
    endShape(CLOSE);
  }
  void drawSelected() {
    // draw shape poly
    strokeWeight(3);
    stroke(0,0,0);
    noFill();
    beginShape();
    for (int i = 0; i < points.size(); i++) {
      Point p = points.get(i);

      vertex(p.x+100, p.y+100);
    }
    endShape(CLOSE);
    // draw vertices
    for (int i = 0; i < points.size(); i++) {
      Point p = points.get(i);
      stroke(0);
      strokeWeight(1);
      if (dist(mouseX - 100, mouseY - 100, p.x, p.y) < 10) {
        fill(150);
      } else {
        fill(255);
      }
      if (i != selectedVertex) 
        ellipse(p.x + 100, p.y + 100, 20, 20);
      if (i == selectedVertex) {
        strokeWeight(2);
        stroke(0);
        noFill();
        ellipse(p.x + 100, p.y + 100, 40, 40);

      }
    }
    // check to delete vertex
    for (int i = 0; i < points.size(); i++) {
      Point p = points.get(i);
      if (dist(mouseX-100, mouseY-100,p.x,p.y) < 10) {
        if (keyIsPressed && key == 'x' && selectedVertex != i) {
          points.remove(i);
          if (points.size() <= 2) {
            shapes.remove(selected);
            selected = -1;
            selectedVertex = -1;
          }
          break;
        }
      }
    }
    // midpoints
    for (int i = 0; i < points.size(); i++) {
      Point p1 = points.get(i);
      Point p2 = points.get((i+1) % points.size());
      float x = (p1.x+p2.x)/2.0;
      float y = (p1.y+p2.y)/2.0;
      if (dist(x, y, mouseX-100, mouseY-100) < 8) {
        noStroke();
        fill(0);
        ellipse(x+100, y+100, 16,16);
        if (keyIsPressed && key == 'n') {
          points.add(i+1, new Point(x, y));
          keyIsPressed = false;
        }
      } else {
        stroke(0,0,255);
        noFill();
        strokeWeight(1);
        ellipse(x+100, y+100, 16, 16);
      }
    }
    
  }
  
  void selectVertex() {
    selectedVertex = -1;
    for (int i = 0; i < points.size(); i++) {
      Point p = points.get(i);
      if (dist(mouseX - 100, mouseY - 100, p.x, p.y) < 10) {
        selectedVertex = i;
      }
    }
  }
  
  boolean mouseInside() {
    Point mouse = new Point(mouseX-100, mouseY-100); 
    int minX = Integer.MAX_VALUE, maxX = Integer.MIN_VALUE, minY = Integer.MAX_VALUE, maxY = Integer.MIN_VALUE;
    for (Point p : points) {
      minX = min(minX, p.x);
      maxX = max(maxX, p.x);
      minY = min(minY, p.y);
      maxY = max(maxY, p.y);
    }
    if (mouse.x < minX || mouse.x > maxX || mouse.y < minY || mouse.y > maxY) {
      return false;
    }
    int intersects = 0;
    for (int i = 0; i < points.size(); i++) {
      Point p1 = points.get(i);
      Point p2 = points.get((i+1) % points.size());
      if (new LineIntersect().check(p1, p2, new Point(-100, mouse.y), 
      new Point(mouse.x, mouse.y))) {
        intersects++;
      }
    }
    return intersects % 2 == 1;
  }
}
void draw() {
  background(255,255,255);
  stroke(0);
  strokeWeight(1);
  fill(255,255,255);
  rect(100, 100, 800, 800);
  // draw all shapes
  for (int i = 0; i < shapes.size(); i++) {
    Shape shape = shapes.get(i);
    shape.draw();
  }
  // draw selected shape
  if (selected != -1) {
    shapes.get(selected).drawSelected();
  }
  // add new shape
  if (keyIsPressed && selectedVertex == -1 && key == 'a') {
    shapes.add(new Shape(color(r,g,b)));
    selected = shapes.size() - 1;
    selectedVertex = -1;
    keyIsPressed = false;
  }
  // save
  if (keyIsPressed && key == 's') {
    String[] exportData = new String[shapes.size()];
    for (int i = 0; i < shapes.size(); i++) {
      Shape s = shapes.get(i);
      exportData[i] = hex(s.c) + "";
      for (int n = 0; n < s.points.size(); n++) {
        exportData[i] = exportData[i] + " " + s.points.get(n).toString();
      }
      System.out.println(exportData[i]);
    }
    saveStrings("data.txt", exportData);
    keyIsPressed = false;
  }
  if (keyIsPressed && key == 'p') {
    System.out.println();
    System.out.println("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
    System.out.println("<!-- Generator: Adobe Illustrator 16.0.4, SVG Export Plug-In . SVG Version: 6.00 Build 0)  -->");
    System.out.println("<svg version=\"1.1\" id=\"Layer_1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" width=\"800px\" height=\"800px\" viewBox=\"0 0 800 800\" enable-background=\"new 0 0 800 800\" xml:space=\"preserve\">");
    for (Shape s : shapes) {
      color c = s.c;
      System.out.print("<polygon fill=\"#");
      System.out.print(hex(c, 6));
      System.out.print("\" points=\"");
      for (Point p : s.points) {
        System.out.print(p.x + "," + p.y + " ");
      }
      System.out.println("\"/>");
    }
    System.out.println("</svg>");
    keyIsPressed = false;
  }
  if (keyIsPressed && key == CODED && keyCode == UP && selected > -1 && selected < shapes.size()-1) {
    Shape temp = shapes.get(selected);
    shapes.set(selected, shapes.get(selected+1));
    shapes.set(selected+1, temp);
    keyIsPressed = false;
    selected++;
  }
  if (keyIsPressed && key == CODED && keyCode == DOWN && selected >=1 ) {
    Shape temp = shapes.get(selected);
    shapes.set(selected, shapes.get(selected-1));
    shapes.set(selected-1, temp);
    keyIsPressed = false;
    selected--;
  }
  if (keyIsPressed && key == 'k' && selected != -1) {
    shapes.remove(selected);
    selected = -1;
    selectedVertex = -1;
    keyIsPressed = false;
  }
  
  fill(0);
  noStroke();
  textSize(15);
  text("A: new shape \nN: new vertex at edge\nX: delete vertex \nk: delete shape", 30, height-80);
  text("S: save to data.txt\n UP: bring shape forward \n DOWN: bring shape backwards", 200, height-80);
  
  text("Color Picker", 500, height-80);
  text("R", 570, height-60);
  text("G", 570, height-40);
  text("B", 570, height-20);
  text(r, 910, height-60);
  text(g, 910, height-40);
  text(b, 910, height-20);

  if (selectedSlider == 1) {
    r = constrain(floor(map(mouseX, 600, 900, 0, 255) / 25) * 25, 0, 255);
  }
  if (selectedSlider == 2) {
    g = constrain(floor(map(mouseX, 600, 900, 0, 255) / 25) * 25, 0, 255);
  }
  if (selectedSlider == 3) {
    b = constrain(floor(map(mouseX, 600, 900, 0, 255) / 25) * 25, 0, 255);
  }
  if (selectedSlider != -1 && selected != -1) {
    shapes.get(selected).c = color(r,g,b); 
  }
  // slider boxes
  stroke(0);
  fill(255);
  if (selectedSlider == 1 || (selectedSlider == -1 && mouseX <= 900 && mouseX >= 600 && mouseY <= height-60 && mouseY >= height-60-10)) {
    strokeWeight(3);
  } else { 
    strokeWeight(1);
  }
  rect(600, height-60, 300, -10);  
  if (selectedSlider == 2 || (selectedSlider == -1 && mouseX <= 900 && mouseX >= 600 && mouseY <= height-40 && mouseY >= height-40-10)) {
    strokeWeight(3);
  } else { 
    strokeWeight(1);
  }
  rect(600, height-40, 300, -10); 
  if (selectedSlider == 3 || (selectedSlider == -1 && mouseX <= 900 && mouseX >= 600 && mouseY <= height-20 && mouseY >= height-20-10)) {
    strokeWeight(3);
  } else { 
    strokeWeight(1);
  }
  rect(600, height-20, 300, -10);
  // slider knobs
  noStroke();
  fill(0);
  rect(lerp(600, 900, r/255.0)-2.5, height-60, 5, -10);
  rect(lerp(600, 900, g/255.0)-2.5, height-40, 5, -10);
  rect(lerp(600, 900, b/255.0)-2.5, height-20, 5, -10);
  // color indicator
  fill(color(r,g,b));
  stroke(0);
  strokeWeight(1);
  rect(500, height-70, 50, 50);
  // copied color
  fill(copiedColor);
  rect(600, height-75, 20, -20);
  // copy buttons
  fill(255);
  stroke(0);
  strokeWeight(1);
  if (selectedSlider == -1 && selectedVertex == -1 && mouseX >=630 && mouseX <= 680 && mouseY <= height-75 && mouseY >= height-95) 
    strokeWeight(3);
  rect(630, height-75, 50, -20);
  textSize(20);
  fill(0);
  noStroke();
  text("copy", 633, height-78);
  // paste button
  fill(255);
  stroke(0);
  strokeWeight(1);
  if (selectedSlider == -1 && selectedVertex == -1 && mouseX >=690 && mouseX <= 740 && mouseY <= height-75 && mouseY >= height-95) 
    strokeWeight(3);
  rect(690, height-75, 50, -20);
  textSize(20);
  fill(0);
  noStroke();
  text("paste", 693, height-78);
}
void mousePressed() {
  if (mouseX >= 100 && mouseX <= 900 && mouseY >= 100 && mouseY <= 900) {
    if (selected != -1) {
      shapes.get(selected).selectVertex();
      if (selectedVertex == -1) {
        selected = -1;
        for (int i = 0; i < shapes.size(); i++) {
          Shape shape = shapes.get(i);
          if (shape.mouseInside()) {
            selected = i;
            r = (int) red(shape.c);
            g = (int) green(shape.c);
            b = (int) blue(shape.c);
          }
        }
      }
    } else {
      for (int i = 0; i < shapes.size(); i++) {
        Shape shape = shapes.get(i);
        if (shape.mouseInside()) {
          selected = i;
            r = (int) red(shape.c);
            g = (int) green(shape.c);
            b = (int) blue(shape.c);
        }
      }
    }
  }

  if (selectedVertex == -1 && selectedSlider == -1) {
    if (mouseX <= 900 && mouseX >= 600 && mouseY <= height-60 && mouseY >= height-60-10) {
      selectedSlider = 1;
    }
    else if (mouseX <= 900 && mouseX >= 600 && mouseY <= height-40 && mouseY >= height-40-10) {
      selectedSlider = 2;
    }
    else if (mouseX <= 900 && mouseX >= 600 && mouseY <= height-20 && mouseY >= height-20-10) {
      selectedSlider = 3;
    }
  }
  // copy
  if (selectedSlider == -1 && selectedVertex == -1 && mouseX >=630 && mouseX <= 680 && mouseY <= height-75 && mouseY >= height-95) {
    copiedColor = color(r,g,b);
  }
  if (selectedSlider == -1 && selectedVertex == -1 && mouseX >=690 && mouseX <= 740 && mouseY <= height-75 && mouseY >= height-95) {
    if (selected != -1) {
      shapes.get(selected).c = copiedColor;  
        r = (int) red(shapes.get(selected).c);
        g = (int) green(shapes.get(selected).c);
        b = (int) blue(shapes.get(selected).c);
     }
  }

}
void mouseDragged() {
  if (selectedVertex != -1) {
    Point vertex = shapes.get(selected).points.get(selectedVertex);
    vertex.x = mouseX - 100;
    vertex.y = mouseY - 100;
    if (vertex.x < 0) vertex.x = 0;
    if (vertex.y < 0) vertex.y = 0;
    if (vertex.x > 800) vertex.x = 800;
    if (vertex.y > 800) vertex.y = 800;
  }
}
void mouseReleased() {
  selectedVertex = -1;
  selectedSlider = -1;
}
void keyPressed() {
  keyIsPressed = true;
}
void keyReleased() {
  keyIsPressed = false;
}