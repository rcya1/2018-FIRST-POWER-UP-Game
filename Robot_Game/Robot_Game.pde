import shiffman.box2d.*;
import org.jbox2d.dynamics.contacts.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;

import java.util.Random;
import com.studiohartman.jamepad.*;
import com.studiohartman.jamepad.tester.*;
import com.badlogic.gdx.jnigen.*;
import com.badlogic.gdx.jnigen.parsing.*;
import com.badlogic.gdx.jnigen.test.*;
import com.github.javaparser.*;
import com.github.javaparser.ast.*;
import com.github.javaparser.ast.body.*;
import com.github.javaparser.ast.comments.*;
import com.github.javaparser.ast.expr.*;
import com.github.javaparser.ast.internal.*;
import com.github.javaparser.ast.stmt.*;
import com.github.javaparser.ast.type.*;
import com.github.javaparser.ast.visitor.*;

import java.util.Iterator;
import java.awt.geom.PathIterator;
import java.awt.geom.AffineTransform;
import java.awt.geom.Area;
import java.awt.Rectangle;
import java.util.HashSet;

Box2DProcessing box2D;

static final int FPS = 60;

HashSet<Character> keysPressed;
HashSet<Integer> keyCodes;

Robot player1;
Robot player2;
ArrayList<Cube> cubes;
Area fenceHorizontal;
Area fenceVertical;

int fenceWidth;
int markingThickness;

ArrayList<Balance> balances;

int[] score;
int timer;
int countDown;
int countDownAlpha;
int time, prevTime;

ControllerManager controllers;

void setup()
{
  size(1000, 600);
  // fullScreen();
  frameRate(FPS);
  
  box2D = new Box2DProcessing(this);
  box2D.createWorld();
  box2D.listenForCollisions();
  box2D.setGravity(0, 0);
  
  keysPressed = new HashSet<Character>();
  keyCodes = new HashSet<Integer>();
  
  controllers = new ControllerManager();
  controllers.initSDLGamepad();
  
  cubes = new ArrayList<Cube>();
  balances = new ArrayList<Balance>();
  
  resetGame();
}

void resetGame()
{
  if(player1 != null) player1.removeFromWorld();
  if(player2 != null) player2.removeFromWorld();

  player1 = new Robot(width / 10, height / 2, width / 20, height / 7, 90, color(255, 175, 175), 
    color(255, 150, 150), true);
  player2 = new Robot(width - width / 10, height / 2, width / 20, height / 7, 270, 
    color(175, 175, 255), color(150, 150, 255), false);
  
  for(Cube cube : cubes) cube.removeFromWorld();
  cubes.clear();
  
  float initY = height / 3 + width / 110;
  float endY = height / 3 - width / 110 + height / 3;
  float steppingY = (endY - initY) / 5;
  
  float leftX = width / 4 + width / 30 + width / 110;
  float rightX = width * 3.0 / 4 - width / 30 - width / 110;
  
  cubes.add(new Cube(leftX, initY + 0 * steppingY));
  cubes.add(new Cube(leftX, initY + 1 * steppingY));
  cubes.add(new Cube(leftX, initY + 2 * steppingY));
  cubes.add(new Cube(leftX, initY + 3 * steppingY));
  cubes.add(new Cube(leftX, initY + 4 * steppingY));
  cubes.add(new Cube(leftX, initY + 5 * steppingY));
  
  cubes.add(new Cube(rightX, initY + 0 * steppingY));
  cubes.add(new Cube(rightX, initY + 1 * steppingY));
  cubes.add(new Cube(rightX, initY + 2 * steppingY));
  cubes.add(new Cube(rightX, initY + 3 * steppingY));
  cubes.add(new Cube(rightX, initY + 4 * steppingY));
  cubes.add(new Cube(rightX, initY + 5 * steppingY));
  
  initY = height / 2;
  float step = height * 1.65 / 55;
  
  leftX = width / 4 - width / 30 - width / 110;
  rightX = width * 3.0 / 4 + width / 30 + width / 110;
  
  cubes.add(new Cube(leftX, initY));
  cubes.add(new Cube(leftX, initY - step));
  cubes.add(new Cube(leftX, initY + step));
  cubes.add(new Cube(leftX - step, initY - step / 2));
  cubes.add(new Cube(leftX - step, initY + step / 2));
  cubes.add(new Cube(leftX - step * 2, initY));
  
  cubes.add(new Cube(rightX, initY));
  cubes.add(new Cube(rightX, initY - step));
  cubes.add(new Cube(rightX, initY + step));
  cubes.add(new Cube(rightX + step, initY - step / 2));
  cubes.add(new Cube(rightX + step, initY + step / 2));
  cubes.add(new Cube(rightX + step * 2, initY));
  
  
  for(Balance balance : balances) balance.removeFromWorld();
  balances.clear();
  
  balances = new ArrayList<Balance>();
  balances.add(new Balance(width / 2, height / 2, width / 12.5, height / 2, true, Math.random() < 0.5, false)); //Scale
  balances.add(new Balance(width / 4, height / 2, width / 15, height / 3, false, Math.random() < 0.5, true)); //Left Switch
  balances.add(new Balance(width * 3.0 / 4, height / 2, width / 15, height / 3, false, Math.random() < 0.5, false)); //Right Switch
  
  fenceWidth = width / 40;
  new Boundary(width / 2, 0, width, fenceWidth * 2);
  new Boundary(width / 2, height, width, fenceWidth * 2);
  new Boundary(0, height / 2, fenceWidth * 2, height);
  new Boundary(width, height / 2, fenceWidth * 2, height);

  markingThickness = width / 100;

  score = new int[] {0, 0};
  countDown = COUNTDOWN_LENGTH;
  countDownAlpha = 255;
  timer = MATCH_LENGTH;
  
  time = millis();
  prevTime = millis();
}

void draw()
{
  update();
  drawSprites();
  // println(frameRate);
}

void update()
{
  controllers.update();
  player1.input(keysPressed, keyCodes, controllers.getState(0));
  player2.input(keysPressed, keyCodes, controllers.getState(1));
  
  box2D.step();
  
  player1.update(cubes, balances);
  player2.update(cubes, balances);
  
  for(Cube cube : cubes)
  {
    cube.update();
  }
  
  for(Balance balance : balances)
  {
    balance.update(cubes);
  }
}

void drawSprites()
{
  background(135, 136, 136);
  rectMode(CENTER);

  float step = height * 1.65 / 55;
  
  float leftX = width / 4 - width / 30 - width / 110;
  float rightX = width * 3.0 / 4 + width / 30 + width / 110;

  fill(255);
  noStroke();
  //Draw auto lines
  rect(leftX - step, height / 2, markingThickness, height - fenceWidth * 2);
  rect(rightX + step, height / 2, markingThickness, height - fenceWidth * 2);

  //Draw null zone lines
  rect(width / 2 - width / 18 + markingThickness / 2, height * 7 / 8.0 - fenceWidth / 2 + markingThickness / 2, 
    markingThickness, height / 4 - fenceWidth - markingThickness + 2);
  rect(width / 2 + width / 18 - markingThickness / 2, height * 7 / 8.0 - fenceWidth / 2 + markingThickness / 2, 
    markingThickness, height / 4 - fenceWidth - markingThickness + 2);
  rect(width / 2, height * 3 / 4.0 + markingThickness / 2, width / 9, markingThickness);

  rect(width / 2 - width / 18 + markingThickness / 2, height * 1 / 8.0 + fenceWidth / 2 - markingThickness / 2, 
    markingThickness, height / 4 - fenceWidth - markingThickness + 2);
  rect(width / 2 + width / 18 - markingThickness / 2, height * 1 / 8.0 + fenceWidth / 2 - markingThickness / 2, 
    markingThickness, height / 4 - fenceWidth - markingThickness + 2);
  rect(width / 2, height * 1 / 4.0 - markingThickness / 2, width / 9, markingThickness);

  //Draw the middle wire carry
  fill(0);
  rect(width / 2, height / 2, markingThickness, height - fenceWidth * 2);

  int platformSlopeWidth = 10;

  //Draw red centerline and platform
  fill(255, 0, 0);
  rect((width / 4 - width / 25 + fenceWidth) / 2, height / 2, width / 4 - width / 25 - fenceWidth / 2, markingThickness);

  stroke(0);
  rect(width / 2 - width / 50 - width / 30 + platformSlopeWidth / 2, height / 2,
    width / 15 - platformSlopeWidth, height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2);
  fill(195, 0, 0);
  beginShape();
    vertex(width / 2 - width / 50 - width / 30 + platformSlopeWidth / 2 + (width / 15 - platformSlopeWidth) / 2, 
        height / 2 - (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2);
    vertex(width / 2 - width / 50 - width / 30 + platformSlopeWidth / 2 + (width / 15 - platformSlopeWidth) / 2, 
        height / 2 - (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2 - platformSlopeWidth);
    vertex(width / 2 - width / 50 - width / 30 + platformSlopeWidth / 2 - (width / 15 - platformSlopeWidth) / 2 - platformSlopeWidth, 
        height / 2 - (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2 - platformSlopeWidth);
    vertex(width / 2 - width / 50 - width / 30 + platformSlopeWidth / 2 - (width / 15 - platformSlopeWidth) / 2, 
        height / 2 - (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2);
  endShape(CLOSE);
  beginShape();
    vertex(width / 2 - width / 50 - width / 30 + platformSlopeWidth / 2 + (width / 15 - platformSlopeWidth) / 2, 
        height / 2 + (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2);
    vertex(width / 2 - width / 50 - width / 30 + platformSlopeWidth / 2 + (width / 15 - platformSlopeWidth) / 2, 
        height / 2 + (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2 + platformSlopeWidth);
    vertex(width / 2 - width / 50 - width / 30 + platformSlopeWidth / 2 - (width / 15 - platformSlopeWidth) / 2 - platformSlopeWidth, 
        height / 2 + (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2 + platformSlopeWidth);
    vertex(width / 2 - width / 50 - width / 30 + platformSlopeWidth / 2 - (width / 15 - platformSlopeWidth) / 2, 
        height / 2 + (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2);
  endShape(CLOSE);
  beginShape();
    vertex(width / 2 - width / 50 - width / 30 + platformSlopeWidth / 2 - (width / 15 - platformSlopeWidth) / 2 - platformSlopeWidth, 
        height / 2 + (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2 + platformSlopeWidth);
    vertex(width / 2 - width / 50 - width / 30 + platformSlopeWidth / 2 - (width / 15 - platformSlopeWidth) / 2, 
        height / 2 + (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2);
    vertex(width / 2 - width / 50 - width / 30 + platformSlopeWidth / 2 - (width / 15 - platformSlopeWidth) / 2, 
        height / 2 - (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2);
    vertex(width / 2 - width / 50 - width / 30 + platformSlopeWidth / 2 - (width / 15 - platformSlopeWidth) / 2 - platformSlopeWidth, 
        height / 2 - (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2 - platformSlopeWidth);
  endShape(CLOSE);
  noStroke();

  //Draw blue centerline and platform
  fill(0, 0, 255);
  rect((width * 3.0 / 4 + width * 24.0 / 25 + fenceWidth) / 2, height / 2, 
    width / 4 - width / 25 + fenceWidth / 2, markingThickness);

  stroke(0);
  rect(width / 2 + width / 50 + width / 30 - platformSlopeWidth / 2, height / 2,
    width / 15 - platformSlopeWidth, height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2);
  fill(0, 0, 195);
  beginShape();
    vertex(width / 2 + width / 50 + width / 30 - platformSlopeWidth / 2 - (width / 15 - platformSlopeWidth) / 2, 
        height / 2 - (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2);
    vertex(width / 2 + width / 50 + width / 30 - platformSlopeWidth / 2 - (width / 15 - platformSlopeWidth) / 2, 
        height / 2 - (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2 - platformSlopeWidth);
    vertex(width / 2 + width / 50 + width / 30 - platformSlopeWidth / 2 + (width / 15 - platformSlopeWidth) / 2 + platformSlopeWidth, 
        height / 2 - (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2 - platformSlopeWidth);
    vertex(width / 2 + width / 50 + width / 30 - platformSlopeWidth / 2 + (width / 15 - platformSlopeWidth) / 2, 
        height / 2 - (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2);
  endShape(CLOSE);
  beginShape();
    vertex(width / 2 + width / 50 + width / 30 - platformSlopeWidth / 2 - (width / 15 - platformSlopeWidth) / 2, 
        height / 2 + (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2);
    vertex(width / 2 + width / 50 + width / 30 - platformSlopeWidth / 2 - (width / 15 - platformSlopeWidth) / 2, 
        height / 2 + (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2 + platformSlopeWidth);
    vertex(width / 2 + width / 50 + width / 30 - platformSlopeWidth / 2 + (width / 15 - platformSlopeWidth) / 2 + platformSlopeWidth, 
        height / 2 + (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2 + platformSlopeWidth);
    vertex(width / 2 + width / 50 + width / 30 - platformSlopeWidth / 2 + (width / 15 - platformSlopeWidth) / 2, 
        height / 2 + (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2);
  endShape(CLOSE);
  beginShape();
    vertex(width / 2 + width / 50 + width / 30 - platformSlopeWidth / 2 + (width / 15 - platformSlopeWidth) / 2 + platformSlopeWidth, 
        height / 2 + (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2 + platformSlopeWidth);
    vertex(width / 2 + width / 50 + width / 30 - platformSlopeWidth / 2 + (width / 15 - platformSlopeWidth) / 2, 
        height / 2 + (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2);
    vertex(width / 2 + width / 50 + width / 30 - platformSlopeWidth / 2 + (width / 15 - platformSlopeWidth) / 2, 
        height / 2 - (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2);
    vertex(width / 2 + width / 50 + width / 30 - platformSlopeWidth / 2 + (width / 15 - platformSlopeWidth) / 2 + platformSlopeWidth, 
        height / 2 - (height / 2 - width / 12.5 * 2 - platformSlopeWidth * 2) / 2 - platformSlopeWidth);
  endShape(CLOSE);
  noStroke();

  stroke(0);

  //Draw the borders
  fill(120);
  rect(width / 2, fenceWidth / 2, width, fenceWidth);
  rect(width / 2, height - fenceWidth / 2, width, fenceWidth);
  
  fill(255, 0, 0);
  rect(fenceWidth / 2, height / 2, fenceWidth, height - fenceWidth * 2);
  
  fill(0, 0, 255);
  rect(width - fenceWidth / 2, height / 2, fenceWidth, height - fenceWidth * 2);
  
  stroke(0);
  
  //Draw shadows on the scale
  balances.get(0).drawShadows();
  
  player1.draw();
  player2.draw();
  
  for(Balance balance : balances)
  {
    balance.draw();
  }
  
  for(Cube cube : cubes)
  {
    cube.draw();
  }
  
  textSize(height / 15);
  
  fill(255);
  textSize(width / 25);
  textAlign(CENTER);
  text(score[0], width / 3, height / 10);
  text(score[1], width * 2.0 / 3, height / 10);
  text(timer, width / 2, height / 10);
  
  if(frameCount == 1) prevTime = millis();
  if(countDown != 0)
  {
    time = millis();
    if(time - prevTime >= 1000)
    {
      prevTime = time;
      countDown--;
      countDownAlpha = 255;
    }
  }
  if(countDownAlpha > 0)
  {
    String countDownText = countDown == 0 ? "POWER UP!" : Integer.toString(countDown);
    
    textSize(width / 10);
    textAlign(CENTER, CENTER);

    fill(255, countDownAlpha);
    text(countDownText, width / 2, height / 2 - 10);
    countDownAlpha -= 5;
  }
}

void drawArea(Area area, color fillColor)
{
  fill(fillColor);
  PathIterator iterator = area.getPathIterator(null);
  while(!iterator.isDone())
  {
    float[] coords = new float[6];
    int type = iterator.currentSegment(coords);
    
    if(type == PathIterator.SEG_MOVETO)
    {
      beginShape();
      vertex(coords[0], coords[1]);
    }
    else if(type == PathIterator.SEG_LINETO) vertex(coords[0], coords[1]);
    else if(type == PathIterator.SEG_CLOSE) endShape();
    
    iterator.next();
  }
}

void keyPressed()
{
  if(countDown == 0)
  {
    keysPressed.add(Character.toLowerCase(key));
    keyCodes.add(keyCode);
    
    if(keysPressed.contains('r')) resetGame();
  }
}

void keyReleased()
{
  keysPressed.remove(Character.toLowerCase(key));
  keyCodes.remove(keyCode); 
}