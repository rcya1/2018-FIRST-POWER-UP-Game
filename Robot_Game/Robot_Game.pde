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

static final int FPS = 60;

HashSet<Character> keysPressed;
HashSet<Integer> keyCodes;

Robot player1;
Robot player2;
ArrayList<Cube> cubes;
ArrayList<Area> objects;
Area fenceHorizontal;
Area fenceVertical;
int fenceWidth;

ArrayList<Balance> balances;

int[] score;

ControllerManager controllers;

final int SCALE = 0;
final int LEFT_SWITCH = 1;
final int RIGHT_SWITCH = 2;

void setup()
{
  size(1000, 600);
  //fullScreen();
  frameRate(FPS);
  
  keysPressed = new HashSet<Character>();
  keyCodes = new HashSet<Integer>();
  
  controllers = new ControllerManager();
  controllers.initSDLGamepad();
  
  player1 = new Robot(width / 10, height / 2, width / 20, height / 6, 90, color(200), color(150), true);
  player2 = new Robot(width - width / 10, height / 2, width / 20, height / 6, 270, color(200), color(150), false);
  
  player1.setOppRobot(player2);
  player2.setOppRobot(player1);
  
  cubes = new ArrayList<Cube>();
  
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
  
  cubes.add(new Cube(leftX, initY - step / 2));
  cubes.add(new Cube(leftX, initY + step / 2));
  cubes.add(new Cube(leftX - step, initY));
  
  cubes.add(new Cube(leftX, initY));
  
  
  
  cubes.add(new Cube(rightX, initY));
  cubes.add(new Cube(rightX, initY - step));
  cubes.add(new Cube(rightX, initY + step));
  cubes.add(new Cube(rightX + step, initY - step / 2));
  cubes.add(new Cube(rightX + step, initY + step / 2));
  cubes.add(new Cube(rightX + step * 2, initY));
  
  cubes.add(new Cube(rightX, initY - step / 2));
  cubes.add(new Cube(rightX, initY + step / 2));
  cubes.add(new Cube(rightX + step, initY));
  
  cubes.add(new Cube(rightX, initY));
  
  
  objects = new ArrayList<Area>();
  
  fenceWidth = width / 50;
  fenceHorizontal = new Area(new Rectangle(0, 0, width, fenceWidth));
  fenceHorizontal.add(new Area(new Rectangle(0, 0, fenceWidth, height)));
  fenceVertical = new Area(new Rectangle(width - fenceWidth, 0, fenceWidth, height));
  fenceVertical.add(new Area(new Rectangle(0, height - fenceWidth, width, fenceWidth)));
  
  objects.add(fenceHorizontal);
  objects.add(fenceVertical);
  
  balances = new ArrayList<Balance>();
  balances.add(new Balance(width / 2, height / 2, width / 12.5, height / 2, true, Math.random() < 0.5, false)); //Scale
  balances.add(new Balance(width / 4, height / 2, width / 15, height / 3, false, Math.random() < 0.5, true)); //Left Switch
  balances.add(new Balance(width * 3.0 / 4, height / 2, width / 15, height / 3, false, Math.random() < 0.5, false)); //Right Switch
  
  score = new int[] {0, 0};
}

void draw()
{
  background(255);
  
  controllers.update();
  
  player1.input(keysPressed, keyCodes, controllers.getState(0));
  player2.input(keysPressed, keyCodes, controllers.getState(1));
  
  player1.update(objects, cubes, balances);
  player2.update(objects, cubes, balances);
  
  for(Cube cube : cubes)
  {
    cube.update();
  }
  
  for(Balance balance : balances)
  {
    balance.update(cubes);
  }
  
  noStroke();
  for(Area area : objects)
  {
    drawArea(area, color(120));
  }
  
  rectMode(CENTER);
  
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
  fill(0);
  text(score[0], width / 3, height / 10);
  text(score[1], width * 2.0 / 3, height / 10);
  
  //println(player2.position, player2.velocity, player2.acceleration);
  println(frameRate);
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
  keysPressed.add(Character.toLowerCase(key));
  keyCodes.add(keyCode);
}

void keyReleased()
{
  keysPressed.remove(Character.toLowerCase(key));
  keyCodes.remove(keyCode); 
}

void exit()
{
  controllers.quitSDLGamepad();
}