// Necessary global instances and variables
Matrix4 transform;
float[] angles = new float[6];

// Other global instances and variables
int r;
int g;
int b;

float weight = 1;

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
  
  QuadrilateralPolyhedron square = new QuadrilateralPolyhedron();
  square.addFace(
    new Quadrilateral(
      new Vertex(1, -100, 3, 10),
      new Vertex(2, 3, 4, 5),
      new Vertex(-30, 4, 5, 6),
      new Vertex(4, 5, 6, 700)
    ));
    
  square.render(r, g, b);
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

class TrianglarPolyhedron { // 3D
  ArrayList<Triangle> faces = new ArrayList<>();
  
  void addFace(Triangle tri) {
    faces.add(tri);
  }
  
  TrianglarPolyhedron() {}
  TrianglarPolyhedron(ArrayList<Triangle> triangles) {
    for (Triangle triangle : triangles) {
      faces.add(triangle);
    }
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

boolean arePointsCoHyperplanar(double[] A, double[] B, double[] C, double[] D, double[] E) {
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
  
  /*
  ArrayList<Vertex> vertices = new ArrayList<>();
  ArrayList<Quadrilateral> squares = new ArrayList<>();
  ArrayList<QuadrilateralPolyhedron> cubes = new ArrayList<>();
  vertices.add(new Vertex(center.x + shapeLength, center.y + shapeLength, center.z + shapeLength, center.w + shapeLength));
  vertices.add(new Vertex(center.x - shapeLength, center.y + shapeLength, center.z + shapeLength, center.w + shapeLength));
  vertices.add(new Vertex(center.x + shapeLength, center.y - shapeLength, center.z + shapeLength, center.w + shapeLength));
  vertices.add(new Vertex(center.x - shapeLength, center.y - shapeLength, center.z + shapeLength, center.w + shapeLength)); // 
  vertices.add(new Vertex(center.x + shapeLength, center.y + shapeLength, center.z - shapeLength, center.w + shapeLength));
  vertices.add(new Vertex(center.x - shapeLength, center.y + shapeLength, center.z - shapeLength, center.w + shapeLength));
  vertices.add(new Vertex(center.x + shapeLength, center.y - shapeLength, center.z - shapeLength, center.w + shapeLength));
  vertices.add(new Vertex(center.x - shapeLength, center.y - shapeLength, center.z - shapeLength, center.w + shapeLength));
  vertices.add(new Vertex(center.x + shapeLength, center.y + shapeLength, center.z + shapeLength, center.w - shapeLength));
  vertices.add(new Vertex(center.x - shapeLength, center.y + shapeLength, center.z + shapeLength, center.w - shapeLength));
  vertices.add(new Vertex(center.x + shapeLength, center.y - shapeLength, center.z + shapeLength, center.w - shapeLength));
  vertices.add(new Vertex(center.x - shapeLength, center.y - shapeLength, center.z + shapeLength, center.w - shapeLength));
  vertices.add(new Vertex(center.x + shapeLength, center.y + shapeLength, center.z - shapeLength, center.w - shapeLength));
  vertices.add(new Vertex(center.x - shapeLength, center.y + shapeLength, center.z - shapeLength, center.w - shapeLength));
  vertices.add(new Vertex(center.x + shapeLength, center.y - shapeLength, center.z - shapeLength, center.w - shapeLength));
  vertices.add(new Vertex(center.x - shapeLength, center.y - shapeLength, center.z - shapeLength, center.w - shapeLength));
  
  for (int i = 0; i < vertices.size(); i++) {
    for (int j = i + 1; j < vertices.size(); j++) {
      for (int k = j + 1; k < vertices.size(); k++) {
        for (int l = k + 1; l < vertices.size(); l++) {
          
      }
    }
  }
  */
  
  return new QuadrilateralPolychoron();
}

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
