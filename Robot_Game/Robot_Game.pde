import java.awt.geom.PathIterator;
import java.awt.geom.AffineTransform;
import java.awt.geom.Area;
import java.awt.Rectangle;
import java.util.HashSet;

HashSet<Character> keysPressed;

Robot testRobot;

ArrayList<Area> objects;
Area fenceHorizontal;
Area fenceVertical;
int fenceWidth;

void setup()
{
  size(1000, 600);
  
  keysPressed = new HashSet<Character>();
  
  testRobot = new Robot(width / 2, height / 2, 100, 200, PI / 2, color(200));
  
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
  
  testRobot.input(keysPressed);
  testRobot.update(objects);
  
  for(Area area : objects)
  {
    drawArea(area);
  }
  
  rectMode(CENTER);
  testRobot.draw();
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
  keysPressed.add(key);
}

void keyReleased()
{
  if(keysPressed.contains(key)) keysPressed.remove(key);
}