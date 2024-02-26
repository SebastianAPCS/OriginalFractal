/*
*  Sebastian Dowell, 2024
*  4D Sierpinski Fractal
*/

// Necessary global instances and variables
Matrix4 transform;
float[] angles = new float[6];

// Other global instances and variables
int r;
int g;
int b;

float weight = 0.25;
double s = 100;

// Constants
final double goldenRatio = 1.61803398875;

// Necessary processing functions
void setup() {
  size(800, 600);
  strokeWeight(weight);
  
  angles[0] = 0;
  angles[1] = 0;
  
  updateTransform();
}

void draw() {
  background(0);
  translate(width / 2, height / 2);
  
  float angle = radians(angles[0]);
  
  if (!mousePressed) {
    angles[0] ++;
    angles[1] ++;
    angles[2] ++;
    angles[3] ++;
    angles[4] ++;
    angles[5] ++;
    updateTransform();
  }
  
  // TODO: Improve scuffed rgb logic
  r = (int) (127 + 127 * cos(angle));
  b = (int) (127 + 127 * cos(angle + TWO_PI / 3));
  g = (int) (127 + 127 * cos(angle + 2 * TWO_PI / 3));
 
  /*
  // Example code for rendering a simple 4-polytope
  double o = -0.7236067977499789 * s; // offset
  
  Vertex v1 = new Vertex(2 * s + o, o, o, o);
  Vertex v2 = new Vertex(o, 2 * s + o, o, o);
  Vertex v3 = new Vertex(o, o, 2 * s + o, o);
  Vertex v4 = new Vertex(o, o, o, 2 * s + o);
  Vertex v5 = new Vertex(goldenRatio * s + o, goldenRatio * s + o, goldenRatio * s + o, goldenRatio * s + o);
  
  FiveCell fiveCell = new FiveCell();
  
  fiveCell.addShape(new Tetrahedron(new Vertex[]{v1, v2, v3, v4}));
  fiveCell.addShape(new Tetrahedron(new Vertex[]{v1, v2, v3, v5}));
  fiveCell.addShape(new Tetrahedron(new Vertex[]{v1, v2, v4, v5}));
  fiveCell.addShape(new Tetrahedron(new Vertex[]{v1, v3, v4, v5}));
  fiveCell.addShape(new Tetrahedron(new Vertex[]{v2, v3, v4, v5}));
  
  fiveCell.render(255, 0, 0);
  */
  
  renderSierpinski(3, 0, r, g, b,
    new Vertex(2 * s, 0, 0, 0),
    new Vertex(0, 2 * s, 0, 0),
    new Vertex(0, 0, 2 * s, 0),
    new Vertex(0, 0, 0, 2 * s),
    new Vertex(goldenRatio * s, goldenRatio * s, goldenRatio * s, goldenRatio * s)
  );
}

void mouseDragged() {
  float sensitivity = 0.33;
  float yIncrement = sensitivity * (pmouseY - mouseY);
  float xIncrement = sensitivity * (mouseX - pmouseX);
  
  angles[0] += xIncrement;
  angles[1] += yIncrement;
  
  redraw();
  updateTransform();
}

// Update transform
void updateTransform() {
  float xyAngle = radians(angles[0]);
  float xzAngle = radians(angles[1]);
  float yzAngle = radians(angles[2]);
  float xwAngle = radians(angles[3]);
  float ywAngle = radians(angles[4]);
  float zwAngle = radians(angles[5]);
  
  // Rotation matrices for each plane
  Matrix4 xyRotation = new Matrix4(new double[] {
    cos(xyAngle),  -sin(xyAngle), 0, 0,
    sin(xyAngle),   cos(xyAngle), 0, 0,
    0,              0,            1, 0,
    0,              0,            0, 1
  });

  Matrix4 xzRotation = new Matrix4(new double[] {
    cos(xzAngle), 0, -sin(xzAngle), 0,
    0, 1, 0, 0,
    sin(xzAngle), 0, cos(xzAngle), 0,
    0, 0, 0, 1
  });

  Matrix4 yzRotation = new Matrix4(new double[] {
    1, 0, 0, 0,
    0, cos(yzAngle), -sin(yzAngle), 0,
    0, sin(yzAngle), cos(yzAngle), 0,
    0, 0, 0, 1
  });

  Matrix4 xwRotation = new Matrix4(new double[] {
    cos(xwAngle), 0, 0, -sin(xwAngle),
    0, 1, 0, 0,
    0, 0, 1, 0,
    sin(xwAngle), 0, 0, cos(xwAngle)
  });

  Matrix4 ywRotation = new Matrix4(new double[] {
    1, 0, 0, 0,
    0, cos(ywAngle), 0, -sin(ywAngle),
    0, 0, 1, 0,
    0, sin(ywAngle), 0, cos(ywAngle)
  });

  Matrix4 zwRotation = new Matrix4(new double[] {
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, cos(zwAngle), -sin(zwAngle),
    0, 0, sin(zwAngle), cos(zwAngle)
  });

  transform = xyRotation.multiply(xzRotation)
                        .multiply(yzRotation)
                        .multiply(xwRotation)
                        .multiply(ywRotation)
                        .multiply(zwRotation);
}

void renderTriangles(ArrayList<Triangle> tri, int r, int g, int b) {
  for (Triangle triangle : tri) {
    Vertex v1 = transform.transform(triangle.v1);
    Vertex v2 = transform.transform(triangle.v2);
    Vertex v3 = transform.transform(triangle.v3);
    
    stroke(r, g, b);
    
    line((float) v1.x, (float) v1.y, (float) v2.x, (float) v2.y);
    line((float) v2.x, (float) v2.y, (float) v3.x, (float) v3.y);
    line((float) v3.x, (float) v3.y, (float) v1.x, (float) v1.y);
  }
}

class Vertex { // 1D
  double w;
  double x;
  double y;
  double z;
  
  Vertex(double x, double y, double z, double w) {
    this.w = w;
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

class Triangle { // 2D
  Vertex v1, v2, v3;
  
  Triangle(Vertex v1, Vertex v2, Vertex v3) {
    this.v1 = v1;
    this.v2 = v2;
    this.v3 = v3;
  }
}

class Quadrilateral { // 2D
  Vertex v1, v2, v3, v4;
  
  Quadrilateral(Vertex v1, Vertex v2, Vertex v3, Vertex v4) {
    this.v1 = v1;
    this.v2 = v2;
    this.v3 = v3;
    this.v4 = v4;
  }
}

class Tetrahedron { // 3D
  ArrayList<Triangle> faces = new ArrayList<>();
  
  void addFace(Triangle tri) {
    faces.add(tri);
  }
  
  Tetrahedron() {}
  
  Tetrahedron(ArrayList<Triangle> triangles) {
    for (Triangle triangle : triangles) {
      faces.add(triangle);
    }
  }
  
  Tetrahedron(Vertex[] vertices) { // arraylist doesnt work here :<
    faces.add(new Triangle(vertices[0], vertices[1], vertices[2]));
    faces.add(new Triangle(vertices[0], vertices[1], vertices[3]));
    faces.add(new Triangle(vertices[0], vertices[2], vertices[3]));
    faces.add(new Triangle(vertices[1], vertices[2], vertices[3]));
  }
  
  
  void render(int r, int g, int b) {
    for (Triangle triangle : faces) {
      Vertex v1 = transform.transform(triangle.v1);
      Vertex v2 = transform.transform(triangle.v2);
      Vertex v3 = transform.transform(triangle.v3);
      
      stroke(r, g, b);
      
      line((float) v1.x, (float) v1.y, (float) v2.x, (float) v2.y);
      line((float) v2.x, (float) v2.y, (float) v3.x, (float) v3.y);
      line((float) v3.x, (float) v3.y, (float) v1.x, (float) v1.y);
    }
  }
}

class QuadrilateralPolyhedron { // 3D
  ArrayList<Quadrilateral> faces = new ArrayList<>();
  
  void addFace(Quadrilateral face) {
    faces.add(face);
  }
  
  QuadrilateralPolyhedron() {}
  QuadrilateralPolyhedron(ArrayList<Quadrilateral> quads) {
    for (Quadrilateral quad : quads) {
      faces.add(quad);
    }
  }
  
  void render(int r, int g, int b) {
    for (Quadrilateral quad : faces) {
      Vertex v1 = transform.transform(quad.v1);
      Vertex v2 = transform.transform(quad.v2);
      Vertex v3 = transform.transform(quad.v3);
      Vertex v4 = transform.transform(quad.v4);
      
      stroke(r, g, b);
  
      line((float) v1.x, (float) v1.y, (float) v2.x, (float) v2.y);
      line((float) v2.x, (float) v2.y, (float) v3.x, (float) v3.y);
      line((float) v3.x, (float) v3.y, (float) v4.x, (float) v4.y);
      line((float) v4.x, (float) v4.y, (float) v1.x, (float) v1.y);
    }
  }
}

class QuadrilateralPolychoron { // 4D
  ArrayList<QuadrilateralPolyhedron> shapes = new ArrayList<>();
  
  void addShape(QuadrilateralPolyhedron shape) {
    shapes.add(shape);
  }
  
  QuadrilateralPolychoron() {};
  QuadrilateralPolychoron(ArrayList<QuadrilateralPolyhedron> shapes) {
    for (QuadrilateralPolyhedron shape : shapes) {
      this.shapes.add(shape);
    }
  }
  
  void render(int r, int g, int b) {
    for (QuadrilateralPolyhedron shape : shapes) {
      shape.render(r, g, b);
    }
  }
}

class FiveCell { // 4D
  ArrayList<Tetrahedron> shapes = new ArrayList<>();
  
  void addShape(Tetrahedron shape) {
    shapes.add(shape);
  }
  
  FiveCell() {}
  FiveCell(ArrayList<Tetrahedron> shapes) {
    for (Tetrahedron shape : shapes) {
      this.shapes.add(shape);
    }
  }
  
  void render(int r, int g, int b) {
    for (Tetrahedron shape : shapes) {
      shape.render(r, g, b);
    }
  }
}

void renderSierpinski(int limit, int count, int r, int g, int b, Vertex v1, Vertex v2, Vertex v3, Vertex v4, Vertex v5) {
  if (count >= limit) return;
  
  if (count == 0) {
    // Center the shape
    double[] center = getFiveCellCenter(v1, v2, v3, v4, v5);
    Vertex[] vertices = new Vertex[]{v1, v2, v3, v4, v5};
    
    for (Vertex vertex : vertices) {
      vertex.x -= center[0];
      vertex.y -= center[1];
      vertex.z -= center[2];
      vertex.w -= center[3];
    }
    
    v1 = vertices[0];
    v2 = vertices[1];
    v3 = vertices[2];
    v4 = vertices[3];
    v5 = vertices[4];
  }
  
  // Create a 5-cell
  FiveCell fiveCell = new FiveCell();
  
  fiveCell.addShape(new Tetrahedron(new Vertex[]{v1, v2, v3, v4}));
  fiveCell.addShape(new Tetrahedron(new Vertex[]{v1, v2, v3, v5}));
  fiveCell.addShape(new Tetrahedron(new Vertex[]{v1, v2, v4, v5}));
  fiveCell.addShape(new Tetrahedron(new Vertex[]{v1, v3, v4, v5}));
  fiveCell.addShape(new Tetrahedron(new Vertex[]{v2, v3, v4, v5}));
  
  // Render the 5-cell
  fiveCell.render(r, g, b);
  
  // Recursively create more 5-cells following the sierpinski fractal
  renderSierpinski(limit, count + 1, r, g, b, 
    v1,
    new Vertex((v1.x + v2.x) / 2, (v1.y + v2.y) / 2, (v1.z + v2.z) / 2, (v1.w + v2.w) / 2),
    new Vertex((v1.x + v3.x) / 2, (v1.y + v3.y) / 2, (v1.z + v3.z) / 2, (v1.w + v3.w) / 2),
    new Vertex((v1.x + v4.x) / 2, (v1.y + v4.y) / 2, (v1.z + v4.z) / 2, (v1.w + v4.w) / 2),
    new Vertex((v1.x + v5.x) / 2, (v1.y + v5.y) / 2, (v1.z + v5.z) / 2, (v1.w + v5.w) / 2) 
  );
  
  renderSierpinski(limit, count + 1, r, g, b,
    new Vertex((v1.x + v2.x) / 2, (v1.y + v2.y) / 2, (v1.z + v2.z) / 2, (v1.w + v2.w) / 2),
    v2,
    new Vertex((v2.x + v3.x) / 2, (v2.y + v3.y) / 2, (v2.z + v3.z) / 2, (v2.w + v3.w) / 2),
    new Vertex((v2.x + v4.x) / 2, (v2.y + v4.y) / 2, (v2.z + v4.z) / 2, (v2.w + v4.w) / 2),
    new Vertex((v2.x + v5.x) / 2, (v2.y + v5.y) / 2, (v2.z + v5.z) / 2, (v2.w + v5.w) / 2)
  );
  
  renderSierpinski(limit, count + 1, r, g, b,
    new Vertex((v1.x + v3.x) / 2, (v1.y + v3.y) / 2, (v1.z + v3.z) / 2, (v1.w + v3.w) / 2),
    new Vertex((v2.x + v3.x) / 2, (v2.y + v3.y) / 2, (v2.z + v3.z) / 2, (v2.w + v3.w) / 2),
    v3,
    new Vertex((v3.x + v4.x) / 2, (v3.y + v4.y) / 2, (v3.z + v4.z) / 2, (v3.w + v4.w) / 2),
    new Vertex((v3.x + v5.x) / 2, (v3.y + v5.y) / 2, (v3.z + v5.z) / 2, (v3.w + v5.w) / 2)
  );
  
  renderSierpinski(limit, count + 1, r, g, b,
    new Vertex((v1.x + v4.x) / 2, (v1.y + v4.y) / 2, (v1.z + v4.z) / 2, (v1.w + v4.w) / 2),
    new Vertex((v2.x + v4.x) / 2, (v2.y + v4.y) / 2, (v2.z + v4.z) / 2, (v2.w + v4.w) / 2),
    new Vertex((v3.x + v4.x) / 2, (v3.y + v4.y) / 2, (v3.z + v4.z) / 2, (v3.w + v4.w) / 2),
    v4,
    new Vertex((v4.x + v5.x) / 2, (v4.y + v5.y) / 2, (v4.z + v5.z) / 2, (v4.w + v5.w) / 2)
  );
  
  renderSierpinski(limit, count + 1, r, g, b,
    new Vertex((v1.x + v5.x) / 2, (v1.y + v5.y) / 2, (v1.z + v5.z) / 2, (v1.w + v5.w) / 2),
    new Vertex((v2.x + v5.x) / 2, (v2.y + v5.y) / 2, (v2.z + v5.z) / 2, (v2.w + v5.w) / 2),
    new Vertex((v3.x + v5.x) / 2, (v3.y + v5.y) / 2, (v3.z + v5.z) / 2, (v3.w + v5.w) / 2),
    new Vertex((v4.x + v5.x) / 2, (v4.y + v5.y) / 2, (v4.z + v5.z) / 2, (v4.w + v5.w) / 2),
    v5
  );
}

double[] getFiveCellCenter(Vertex v1, Vertex v2, Vertex v3, Vertex v4, Vertex v5) {
  return new double[]{
    (v1.x + v2.x + v3.x + v4.x + v5.x) / 5,
    (v1.y + v2.y + v3.y + v4.y + v5.y) / 5,
    (v1.z + v2.z + v3.z + v4.z + v5.z) / 5,
    (v1.w + v2.w + v3.w + v4.w + v5.w) / 5
  };
}

// Incomplete code
/*
boolean arePointsCoHyperplanar(double[] A, double[] B, double[] C, double[] D) {
  // Very hard :>
  return false;
}

QuadrilateralPolychoron generateTesseract(int shapeLength, Vertex center) {
  Vertex v1 = new Vertex(center.x + shapeLength, center.y + shapeLength, center.z + shapeLength, center.w + shapeLength);
  Vertex v2 = new Vertex(center.x - shapeLength, center.y + shapeLength, center.z + shapeLength, center.w + shapeLength);
  Vertex v3 = new Vertex(center.x + shapeLength, center.y - shapeLength, center.z + shapeLength, center.w + shapeLength);
  Vertex v4 = new Vertex(center.x - shapeLength, center.y - shapeLength, center.z + shapeLength, center.w + shapeLength);
  Vertex v5 = new Vertex(center.x + shapeLength, center.y + shapeLength, center.z - shapeLength, center.w + shapeLength);
  Vertex v6 = new Vertex(center.x - shapeLength, center.y + shapeLength, center.z - shapeLength, center.w + shapeLength);
  Vertex v7 = new Vertex(center.x + shapeLength, center.y - shapeLength, center.z - shapeLength, center.w + shapeLength);
  Vertex v8 = new Vertex(center.x - shapeLength, center.y - shapeLength, center.z - shapeLength, center.w + shapeLength);
  Vertex v9 = new Vertex(center.x + shapeLength, center.y + shapeLength, center.z + shapeLength, center.w - shapeLength);
  Vertex v10 = new Vertex(center.x - shapeLength, center.y + shapeLength, center.z + shapeLength, center.w - shapeLength);
  Vertex v11 = new Vertex(center.x + shapeLength, center.y - shapeLength, center.z + shapeLength, center.w - shapeLength);
  Vertex v12 = new Vertex(center.x - shapeLength, center.y - shapeLength, center.z + shapeLength, center.w - shapeLength);
  Vertex v13 = new Vertex(center.x + shapeLength, center.y + shapeLength, center.z - shapeLength, center.w - shapeLength);
  Vertex v14 = new Vertex(center.x - shapeLength, center.y + shapeLength, center.z - shapeLength, center.w - shapeLength);
  Vertex v15 = new Vertex(center.x + shapeLength, center.y - shapeLength, center.z - shapeLength, center.w - shapeLength);
  Vertex v16 = new Vertex(center.x - shapeLength, center.y - shapeLength, center.z - shapeLength, center.w - shapeLength);
  
  //ArrayList<Vertex> vertices = new ArrayList<>();
  //ArrayList<Quadrilateral> squares = new ArrayList<>();
  //ArrayList<QuadrilateralPolyhedron> cubes = new ArrayList<>();
  //vertices.add(new Vertex(center.x + shapeLength, center.y + shapeLength, center.z + shapeLength, center.w + shapeLength));
  //vertices.add(new Vertex(center.x - shapeLength, center.y + shapeLength, center.z + shapeLength, center.w + shapeLength));
  //vertices.add(new Vertex(center.x + shapeLength, center.y - shapeLength, center.z + shapeLength, center.w + shapeLength));
  //vertices.add(new Vertex(center.x - shapeLength, center.y - shapeLength, center.z + shapeLength, center.w + shapeLength)); // 
  //vertices.add(new Vertex(center.x + shapeLength, center.y + shapeLength, center.z - shapeLength, center.w + shapeLength));
  //vertices.add(new Vertex(center.x - shapeLength, center.y + shapeLength, center.z - shapeLength, center.w + shapeLength));
  //vertices.add(new Vertex(center.x + shapeLength, center.y - shapeLength, center.z - shapeLength, center.w + shapeLength));
  //vertices.add(new Vertex(center.x - shapeLength, center.y - shapeLength, center.z - shapeLength, center.w + shapeLength));
  //vertices.add(new Vertex(center.x + shapeLength, center.y + shapeLength, center.z + shapeLength, center.w - shapeLength));
  //vertices.add(new Vertex(center.x - shapeLength, center.y + shapeLength, center.z + shapeLength, center.w - shapeLength));
  //vertices.add(new Vertex(center.x + shapeLength, center.y - shapeLength, center.z + shapeLength, center.w - shapeLength));
  //vertices.add(new Vertex(center.x - shapeLength, center.y - shapeLength, center.z + shapeLength, center.w - shapeLength));
  //vertices.add(new Vertex(center.x + shapeLength, center.y + shapeLength, center.z - shapeLength, center.w - shapeLength));
  //vertices.add(new Vertex(center.x - shapeLength, center.y + shapeLength, center.z - shapeLength, center.w - shapeLength));
  //vertices.add(new Vertex(center.x + shapeLength, center.y - shapeLength, center.z - shapeLength, center.w - shapeLength));
  //vertices.add(new Vertex(center.x - shapeLength, center.y - shapeLength, center.z - shapeLength, center.w - shapeLength));
  
  //for (int i = 0; i < vertices.size(); i++) {
  //  for (int j = i + 1; j < vertices.size(); j++) {
  //    for (int k = j + 1; k < vertices.size(); k++) {
  //      for (int l = k + 1; l < vertices.size(); l++) {
  //        
  //    }
  //  }
  //}
  
  //return new QuadrilateralPolychoron(); // so no error since bad incomplete function
}
*/

// 4D Matrix class
class Matrix4 {
  double[] values;
  
  Matrix4(double[] values) {
    this.values = values;
  }
  
  Matrix4 multiply(Matrix4 other) {
    double[] result = new double[16];
    
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        for (int i = 0; i < 4; i++) {
          result[row * 4 + col] += this.values[row * 4 + i] * other.values[i * 4 + col];
        }
      }
    }
    
    return new Matrix4(result);
  }
  
  Vertex transform(Vertex input) {
    return new Vertex(
      input.w * values[0] + input.x * values[4] + input.y * values[8]  + input.z * values[12],
      input.w * values[1] + input.x * values[5] + input.y * values[9]  + input.z * values[13],
      input.w * values[2] + input.x * values[6] + input.y * values[10] + input.z * values[14],
      input.w * values[3] + input.x * values[7] + input.y * values[11] + input.z * values[15]
    );
  }
}
