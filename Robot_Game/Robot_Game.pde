import java.util.HashSet;

HashSet<Character> keysPressed;

Robot testRobot;

void setup()
{
  size(1000, 600);
  
  keysPressed = new HashSet<Character>();
  
  testRobot = new Robot(width / 2, height / 2, 100, 200, PI / 2, color(200));
}

void draw()
{
  background(255);
  
  testRobot.input(keysPressed);
  testRobot.update();
  
  rectMode(CENTER);
  testRobot.draw();
}

void keyPressed()
{
  keysPressed.add(key);
}

void keyReleased()
{
  if(keysPressed.contains(key)) keysPressed.remove(key);
}