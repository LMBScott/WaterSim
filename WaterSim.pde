//Simple Water Simulator
//By Lachlan Scott 2020

//Wave parameters
int waveCount = 50;
int forceMag = 20;

float waveEq = 0.5;
float eqHeight;

float k = 0.1;
float minK= 0.01;
float maxK = 1.0;

float damping = 0.2;
float minDamping = 0.01;
float maxDamping = 1.0;

float forceDispersion = 0.2;
float minDisp = 0.01;
float maxDisp = 0.5;

//Arrays
waveSeg[] segments;
float[] velDeltas = new float[waveCount];

//Slider Parameters
int sliderSize = 20;
int sliderXOffset = 80;
int sliderYOffset = 30;

//Slider States
boolean clickDampingSlider = false;
boolean clickKSlider = false;
boolean clickDispSlider = false;

//Class to store properties of each wave segment
class waveSeg {
  float pos, vel, acc;
  
  waveSeg(float p, float v, float a) {
    pos = p;
    vel = v;
    acc = a;
  }
  
  void Update() {
    float deltaX = eqHeight - pos;
    acc = -k * deltaX;
    
    pos -= vel;
    vel += acc - vel * damping;
  }
}

//Set up window and populate array of wave segments
void setup() {
    size(600, 400);
    frameRate(30);
    pixelDensity(displayDensity());
    
    segments = new waveSeg[waveCount];
    
    eqHeight = waveEq * height;
    for (int i = 0; i < waveCount; i++) {
        segments [i] = new waveSeg(eqHeight, 0, 0);
    }
}

//Render all visual elements
void draw() {
  background(200);
  updateWaves();
  renderWaves();
  renderControls();
}

//Apply a force to the desired wave segment
void applyForce(int x, int magnitude) {
  int index = min(max(floor(x/(width/waveCount)), 0), waveCount-1);
  segments[index].vel -= magnitude;
}

//Make forces disperse across wave segments and cause segments to move correctly
void updateWaves() {
  //Calculate the difference in positions of each segment and its neighbours, and multiply by forceDispersion to reduce the magnitude
  for (int i = 0; i < waveCount; i++) {
     velDeltas[i] = forceDispersion * ((i > 0 ? segments[i].pos - segments[i-1].pos : 0) + (i < waveCount - 1 ? segments[i].pos - segments[i+1].pos : 0));
  }
  //Update the velocities and positions of each segment to make waves travel
  for (int i = 0; i < waveCount; i++) {
    segments[i].vel += velDeltas[i];
    segments[i].Update();
  }
}

//Draw the wave surface and the water beneath
void renderWaves() {
  stroke(0,0,255);
  fill(0,0,0,0);
  float waveWidth = width/waveCount;
  strokeWeight(waveWidth+5);
  
  //Draw a fitted curve at the water surface, and fill in the space beneath with vertical lines
  beginShape();
  curveVertex(0,segments[0].pos);
  for (int i = 0; i < waveCount; i++) {
      curveVertex((i+1)*waveWidth,segments[i].pos);
      line((i+1)*waveWidth, segments[i].pos, (i+1)*waveWidth, height);
  }
  curveVertex(width,segments[waveCount-1].pos);
  endShape();
}

//Draw the control sliders for the key wave parameters
void renderControls() {
  strokeWeight(5);
  stroke(50);
  
  //Draw Slider Slots
  line(sliderXOffset,sliderYOffset,width - sliderXOffset, sliderYOffset);
  line(sliderXOffset,2*sliderYOffset,width - sliderXOffset, 2*sliderYOffset);
  line(sliderXOffset,3*sliderYOffset,width - sliderXOffset, 3*sliderYOffset);
  
  //Draw Slider Knobs
  fill(255);
  circle(map(damping, minDamping, maxDamping, sliderXOffset, width - sliderXOffset),sliderYOffset,sliderSize);
  circle(map(k, minDamping, maxDamping, sliderXOffset, width - sliderXOffset),2*sliderYOffset,sliderSize);
  circle(map(forceDispersion, minDisp, maxDisp, sliderXOffset, width - sliderXOffset),3*sliderYOffset,sliderSize);
  
  //Draw Slider Labels
  textSize(12);
  textAlign(LEFT, CENTER);
  text("Damping", sliderXOffset/8, sliderYOffset);
  text(damping, width - sliderXOffset, sliderYOffset);
  text("K Value", sliderXOffset/8, 2*sliderYOffset);
  text(k, width - sliderXOffset, 2*sliderYOffset);
  text("Dispersion", sliderXOffset/8, 3*sliderYOffset);
  text(forceDispersion, width - sliderXOffset, 3*sliderYOffset);
}

//Check if/where the mouse is pressed
void mousePressed() {
  //Check whether any slider has been clicked
  clickDampingSlider = dist(mouseX,mouseY,map(damping, minDamping, maxDamping, float(sliderXOffset), float(width - sliderXOffset)),sliderYOffset) < sliderSize/2;
  clickKSlider = dist(mouseX,mouseY,map(k, minK, maxK, float(sliderXOffset), float(width - sliderXOffset)),2*sliderYOffset) < sliderSize/2;
  clickDispSlider = dist(mouseX,mouseY,map(forceDispersion, minDisp, maxDisp, float(sliderXOffset), float(width - sliderXOffset)),3*sliderYOffset) < sliderSize/2;
  
  //If no slider has been clicked, apply force to the wave segment closest to the cursor
  if (!clickDampingSlider && !clickKSlider && !clickDispSlider) {
    applyForce(mouseX, forceMag);
  }
}

//Check whether the mouse has been dragged to allow control of sliders
void mouseDragged() {
  //If a slider has been clicked and dragged, change the corresponding parameter based on where it has been dragged.
  if (clickDampingSlider) {
    damping = min(max(damping + map(mouseX-pmouseX,-width,width, -maxDamping,maxDamping), minDamping), maxDamping);
  }
  if (clickKSlider) {
    k = min(max(k + map(mouseX-pmouseX,-width,width, -maxK, maxK), minK), maxK);
  }
  if (clickDispSlider) {
    forceDispersion = min(max(forceDispersion + map(mouseX-pmouseX,-width,width, -maxDisp,maxDisp), minDisp), maxDisp);
  }
}
