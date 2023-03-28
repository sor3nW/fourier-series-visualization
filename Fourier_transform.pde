import java.io.*;
import java.lang.*;
import java.util.*;

//initialize variables
float t = 0;
float radius = 100;
int sWidth = 750;
int sHeight = 750;
ArrayList<float[]> fourierX = new ArrayList<float[]>();
ArrayList<float[]> fourierY = new ArrayList<float[]>();
ArrayList<Float> pathListx = new ArrayList<Float>();
ArrayList<Float> pathListy = new ArrayList<Float>();
int readyToEpicycle = 0;
int readyToSetup = 0;
int num = 0;
int doneDrawing = 0;

void setup(){
  size(750,750, P3D);
  
  
}

void draw() {
  
  background(0);
  stroke(255);
  noFill();
  if (doneDrawing == 1){
    float x = mouseX;
    float y = mouseY;
    pathListx.add(x);
    pathListy.add(y);
    stroke(255);
    noFill();
    beginShape();
    for (int i = 0; i < pathListx.size(); i++){
      vertex( pathListx.get(i), pathListy.get(i));
    }
    endShape();
  }
  
  if (readyToEpicycle == 3){
    float x = mouseX;
    float y = mouseY;
    pathListx.add(x);
    pathListy.add(y);
    stroke(255);
    noFill();
    beginShape();
    for (int i = 0; i < pathListx.size(); i++){
      vertex( pathListx.get(i), pathListy.get(i));
    }
    endShape();
  }
  
  if (readyToSetup == 1){
     
    
    fourierX = dft(pathListx);
    fourierY = dft(pathListy);
    
    fourierX = sortArrayListByAmp(fourierX);
    fourierY = sortArrayListByAmp(fourierY);
    
    
    pathListx.clear();
    pathListy.clear();
    
    
    
    readyToSetup = 0;
  }
  if (readyToEpicycle == 1){
    
    translate(0,0,-800);
    
    
    line(0 + (sWidth/2),0 + (sHeight/2),sWidth + (sWidth/2),0 + (sHeight/2));
    line(sWidth + (sWidth/2),0 + (sHeight/2),sWidth + (sWidth/2),sHeight + (sHeight/2));
    line(sWidth + (sWidth/2),sHeight + (sHeight/2),0 + (sWidth/2),sHeight + (sHeight/2));
    line(0 + (sWidth/2),sHeight + (sHeight/2),0 + (sWidth/2),0 + (sHeight/2));
    
    
    PVector vx, vy, v;
    vx = epiCycles(sWidth/2 , 0, 0, fourierX);
    vy = epiCycles(0, sHeight/2, HALF_PI, fourierY);
    v = new PVector(vx.x, vy.y);
    
    pathListx.add(0, v.x);
    pathListy.add(0, v.y);
    line(vx.x, vx.y, v.x, v.y);
    line(vy.x, vy.y, v.x, v.y);
    
    beginShape();
    noFill();
    for ( int i = 0; i < pathListx.size(); i++){
      vertex(pathListx.get(i), pathListy.get(i));
    }
    endShape();
    
    float dt = TWO_PI / fourierX.size();
    t += dt;
    if (t > TWO_PI){
      t = 0;
      pathListx.clear();
      pathListy.clear();
    }
  }
}

void mousePressed(){
  readyToEpicycle = 0;
  readyToSetup = 0;
  pathListx.clear();
  pathListy.clear();
  doneDrawing = 1;
  
}


void mouseReleased(){
  readyToEpicycle = 1;
  readyToSetup = 1;
  doneDrawing = 0;
  System.out.println(num);
  
}

void drawingCoords(){
  float radius = 100;
  float t = 0;
  for(int i = 0;i < 100; i++){
    float x = radius * sin(t);
    float y = radius * cos(t);
    pathListx.add(x);
    pathListy.add(y);
    t += TWO_PI/100;
  }
}

public static ArrayList<float[]> sortArrayListByAmp(ArrayList<float[]> inputList) {
    Collections.sort(inputList, new Comparator<float[]>() {
        @Override
        public int compare(float[] o1, float[] o2) {
            return Float.compare(o2[3], o1[3]);
        }
    });
    return inputList;
}

public PVector epiCycles(float x, float y, float rotation, ArrayList<float[]> fourier){
  for (int i = 0; i < fourier.size(); i++){
    float prevx = x;
    float prevy = y;
    float[] array = fourier.get(i);
    float freq = array[2];
    float radius = array[3];
    float phase = array[4];
    
    x += radius * cos(freq * t + phase + rotation);
    y += radius * sin(freq * t + phase + rotation);
    
    stroke(255, 100);
    noFill();
    circle(prevx, prevy, radius * 2);
    stroke(255);
    line(prevx, prevy, x, y);
    
  }
  PVector z;
  z = new PVector(x, y);
  return z;
}

public static ArrayList<float[]> dft(ArrayList<Float> x){
  
  ArrayList<float[]> X = new ArrayList<float[]>();
  float N = x.size();
  
  for (int k = 0; k < N; k++){
    float re = 0;
    float im = 0;
    for (int n = 0; n < N; n++){
      float zeta = (TWO_PI * k * n) / N;
      re += x.get(n) * cos(zeta);
      im -= x.get(n) * sin(zeta);
    }
    re = re/N;
    im = im/N;
    
    float freq = k;
    float amp = (float)Math.sqrt((re * re) + (im * im));
    float phase = atan2(im, re);
    float[] arr = {re, im, freq, amp, phase};
    X.add(arr);
  }
  return X;
}
