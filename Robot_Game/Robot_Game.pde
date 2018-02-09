import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

import java.util.Iterator;
import java.awt.geom.PathIterator;
import java.awt.geom.AffineTransform;
import java.awt.geom.Area;
import java.awt.Rectangle;
import java.util.HashSet;

HashSet<Character> keysPressed;
HashSet<Integer> keyCodes;

Robot player1;
Robot player2;
ArrayList<Cube> cubes;
ArrayList<Area> objects;
Area fenceHorizontal;
Area fenceVertical;
int fenceWidth;

void setup()
{
  size(1000, 600);
  frameRate(45);
  
  keysPressed = new HashSet<Character>();
  keyCodes = new HashSet<Integer>();
  
  player1 = new Robot(width / 6, height / 2, 50, 100, 90, color(200), true, player2);
  player2 = new Robot(width - width / 6, height / 2, 50, 100, 270, color(200), false, player1);
  
  cubes = new ArrayList<Cube>();
  cubes.add(new Cube(width / 3, height / 3));
  
  objects = new ArrayList<Area>();
  
  fenceWidth = 20;
  fenceHorizontal = new Area(new Rectangle(0, 0, width, fenceWidth));
  fenceHorizontal.add(new Area(new Rectangle(0, 0, fenceWidth, height)));
  fenceVertical = new Area(new Rectangle(width - fenceWidth, 0, fenceWidth, height));
  fenceVertical.add(new Area(new Rectangle(0, height - fenceWidth, width, fenceWidth)));
  
  objects.add(fenceHorizontal);
  objects.add(fenceVertical);
}

void draw()
{
  background(255);
  
  player1.input(keysPressed, keyCodes);
  player2.input(keysPressed, keyCodes);
  player1.update(objects, cubes);
  player2.update(objects, cubes);
  
  for(Cube cube : cubes)
  {
    cube.update();
  }
  
  for(Area area : objects)
  {
    drawArea(area);
  }
  
  rectMode(CENTER);
  player1.draw();
  player2.draw();
  
  for(Cube cube : cubes)
  {
    cube.draw();
  }
  
  println(frameRate);
}

void drawArea(Area area)
{
  fill(120);
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