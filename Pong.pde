/* ***********************************************************************
 * Caleb Ji
 * Assigment 2 - Pong
 * CS 1120
 * June 7, 2020
 
 * This program is my own work - CJ 
 * Default is singleplayer mode. To get to the training mode, press '3'
 * To get more information on the gamemodes or settings or how to play, press 'i' or the icon in the top right
 */

//info for the ball
int pongRadius = 20;
float x = 500;
float y = 350;
float angle = PI;
float speed = 7;
Boolean setDelay = false;
int delay = 0;

//info for paddle 1
float easing = 0.05;
float paddleHeight = 100;
float paddleWidth = 12.5;
float paddleY = 300;
float targetY = 300;
float paddleSpeed = 10;
float maxBounceAngle = 5*PI/12; 

//info for paddle 2
float easingAI = 0.05;
float paddleHeightAI = 100;
float paddleWidthAI = 12.5;
float paddleYAI = 300;
float targetYAI = 300;
float paddleSpeedAI = 10;
float maxBounceAngleAI = 5*PI/12;

//game information
Boolean gameStart = false;
String gameMode = "one player";
Boolean highSpeed = false;
Boolean longPaddles = false;
Boolean bigBall = false;
Boolean highPaddleSpeed = false;
Boolean hardAI = true;

//score
int leftScore = 0;
int rightScore = 0;

//info board info
Boolean infoBoardShown = false;


void setup() {
  size(1000, 700);
  smooth();
  //load parameters
  loadGame();
}

void draw() {
  background(255);

  //title display
  if (!gameStart) {
    fill(0);
    textSize(150);
    text("PONG", 300, 300);
    textSize(20);
    text("Press space to start and 'i' for more information", 275, 500);
  }

  //game mode text
  fill(0);
  textSize(15);
  text("gamemode: " + gameMode, 425, 15);

  //info icon
  fill(255);
  ellipse(950, 30, 25, 25);
  fill(0);
  text("i", 948, 35);

  //score display
  if (gameStart) {
    textSize(150);
    // no need for left score in training mode
    if ( gameMode != "training") {
      text(str(leftScore), 200, 200);
    }
    text(str(rightScore), 720, 200);
    //secondary smaller text to make weird effect
    fill(255);
    textSize(140);
    if (gameMode != "training") {
      text(str(leftScore), 203, 195);
    }
    text(str(rightScore), 723, 195);
  }



  //get action if ball hits end walls. 
  if (gameMode == "training") {
    //reset when hit right wall, bounce when hit left wall
    if (x >= 1000 - pongRadius / 2) {
      x = 500;
      y = 350;
      speed = 0;
      rightScore = 0;
      setDelay = true;
      angle = 0;
    } else if (x <= pongRadius / 2) {
      if (angle == PI) {
        angle = 0;
      } else {
        angle = PI - angle;
      }
    }
  } else {
    // warp to center and add point
    if (x >= 1000 - pongRadius / 2) {
      x = 500;
      y = 350;
      speed = 0;
      leftScore += 1;
      setDelay = true;
    } else if (x <= pongRadius / 2) {
      x = 500;
      y = 350;
      speed = 0;
      setDelay = true;
      rightScore += 1;
    }
  }
  //delay for ball when warps to center to allow for reaction
  if (setDelay) {
    delay += 1;
    if (delay > 50) {
      delay = 0;
      setDelay = false;
      if (highSpeed) {
        speed = 14;
      } else {
        speed = 7;
      }
      //randomly select side to send ball, not in training mode
      if (gameMode != "training") {
        int side = int(random(0, 2));
        if (side == 0) {
          angle = PI;
        } else {
          angle = 0;
        }
      }
    }
  }


  // bounce off side walls
  if (y >= 700 - pongRadius / 2) {
    angle *= -1;
  } else if (y <= pongRadius / 2) {
    angle *= -1;
  }

  //hitting paddle
  if (x >= 900 - pongRadius / 2 && x < 900 && y >= paddleY - pongRadius && y <= paddleY + paddleHeight + pongRadius) {
    float relInter = abs((paddleY + paddleHeight / 2) - y); //the distance the y-value is from center of paddle
    float normRelInter = relInter/(paddleHeight/2); // the ratio of the distance the y-value is from center of paddle compared to the length of half the paddle
    if (normRelInter * maxBounceAngle == 0) { //if normRelInter == 0, hits ball right in the center. 
      angle = PI;
    } else {
      angle = PI - normRelInter * maxBounceAngle; // deflect
    }
    //keep score for training mode
    if (gameMode == "training") {
      rightScore += 1;
    }
  }
  //same, but for the second paddle
  if (gameMode != "training") {
    if (x <= 100 + pongRadius / 2 && x > 100 && y >= paddleYAI - pongRadius && y <= paddleYAI + paddleHeightAI + pongRadius) {
      float relInter = abs((paddleYAI + paddleHeightAI / 2) - y);
      float normRelInter = relInter/(paddleHeightAI/2);
      if (normRelInter * maxBounceAngle == 0) {
        angle = 0;
      } else {
        angle = -1 * normRelInter * maxBounceAngle;
      }
    }
  }

  //draws ball
  fill(255);
  ellipse(x, y, pongRadius, pongRadius);

  //key inputs
  if (keyPressed) {
    if (key == CODED) {
      //move paddle 1
      if (keyCode == UP) {
        targetY -= paddleSpeed;
      }
      if (keyCode == DOWN) {
        targetY += paddleSpeed;
      }
    } else {
      if (gameMode == "two players") {
        //move paddle 2
        if (key == 'w') {
          targetYAI -= paddleSpeed;
        }
        if (key == 's') {
          targetYAI += paddleSpeed;
        }
      }
    }
  }

  //moving ball if game start
  if (gameStart) {
    x += round(cos(angle) * speed);
    y += round(sin(angle) * speed);
  } else {
    x = 500;
    y = 350;
  }
  fill(255);

  //move paddles
  // use easing
  paddleY += (targetY - paddleY) * easing;
  //block from moving out of bounds
  if (paddleY < 0) {
    paddleY = 0;
    targetY = 0;
  } else if (paddleY > 700 - paddleHeight) {
    paddleY = 700 - paddleHeight;
    targetY = 700 - paddleHeight;
  }
  rect(900, paddleY, paddleWidth, paddleHeight);

  //move AIpaddle
  //determine where to go
  if (gameStart && cos(angle) < 0 && !hardAI) {
    targetYAI = y - paddleHeightAI / 2;
  }
  if (gameStart && hardAI){
    targetYAI = y - paddleHeightAI / 2;
  }
  // use easing effect
  paddleYAI += (targetYAI - paddleYAI) * easingAI;
  //blocked from moving out of bounds
  if (paddleYAI < 0) {
    paddleYAI = 0;
    targetYAI = 0;
  } else if (paddleYAI > 700 - paddleHeightAI) {
    paddleYAI = 700 - paddleHeightAI;
    targetYAI = 700 - paddleHeightAI;
  }
  //not in training
  if (gameMode != "training") {
    rect(100, paddleYAI, paddleWidthAI, paddleHeightAI);
  }
  //info board and its contents
  if (infoBoardShown) {
    rect(250, 150, 500, 400);
    fill(0);
    text("x", 730, 170);
    text("INFORMATION", 450, 200);
    text("Press 1 for one player (default)", 275, 250);
    text("Press 2 for two players", 275, 275);
    text("Press 3 for training mode", 275, 300);
    text("Use arrow keys to move rightmost paddle", 275, 350);
    text("Use 'w' and 's'to move leftmost paddle (only in two player mode)", 275, 375 );
    text("Press 6 to toggle beserk ball", 275, 425);
    text("Press 7 to toggle big ball", 275, 450);
    text("Press 8 to toggle long paddles", 275, 475);
    text("Press 9 to toggle fast paddles", 275, 500);
  }
}


void keyPressed() {
  //toggle info board
  if (key == 'i') {
    if (infoBoardShown == true) {
      infoBoardShown = false;
    } else {
      infoBoardShown = true;
    }
    resetGame();
  }
  //start game
  if (key == ' ') {
    if (!infoBoardShown) {
      gameStart = true;
    }
  }
  //change game mode and game variables
  if (key == '1') {
    gameMode = "one player";
    resetGame();
  }
  if (key == '2') {
    gameMode = "two players";
    resetGame();
  }
  if (key == '3') {
    gameMode = "training";
    resetGame();
  }
  if (key == '6') {
    if (highSpeed) {
      highSpeed = false;
    } else {
      highSpeed = true;
    }
    loadGame();
  }
  if (key == '7') {
    if (bigBall) {
      bigBall = false;
    } else {
      bigBall = true;
    }
    loadGame();
  }
  if (key == '8') {
    if (longPaddles) {
      longPaddles = false;
    } else {
      longPaddles = true;
    }
    loadGame();
  }
  if (key == '9') {
    if (highPaddleSpeed) {
      highPaddleSpeed = false;
    } else {
      highPaddleSpeed = true;
    }
    loadGame();
  }
}

void mousePressed() {
  if (dist(mouseX, mouseY, 950, 30) <= 25) { // mouse pressed on info button in top right
    if (infoBoardShown) {
      infoBoardShown = false;
    } else {
      infoBoardShown = true;
    }
    resetGame();
  }
  if (infoBoardShown) { // button pressed on x in info board
    if (mouseX >=730 && mouseX <= 740 && mouseY <= 170 && mouseY >= 160) {
      infoBoardShown = false;
    }
  }
}

//reset game for every time called (when parameters changed)
void resetGame() {
  x = 500;
  y = 350;
  angle = PI;
  paddleY = 350 - paddleHeight/2;
  targetY = paddleY;
  paddleYAI = 350 - paddleHeightAI/2;
  targetYAI = paddleYAI;
  gameStart = false;
  rightScore = 0;
  leftScore = 0;
}

void loadGame() {
  //render toggled variables
  if (highSpeed) {
    speed = 14;
  } else {
    speed = 7;
  }

  if (longPaddles) {
    paddleHeight = 200;
    paddleHeightAI = 200;
  } else {
    paddleHeight = 100;
    paddleHeightAI = 100;
  }

  paddleY = 350 - paddleHeight/2;
  targetY = paddleY;
  paddleYAI = 350 - paddleHeightAI/2;
  targetYAI = paddleYAI;

  if (bigBall) {
    pongRadius = 40;
  } else {
    pongRadius = 20;
  }

  if (highPaddleSpeed) {
    paddleSpeed = 20;
    paddleSpeedAI = 20;
    easing = 0.1;
    easingAI = 0.1;
  } else {
    paddleSpeed = 10;
    paddleSpeedAI = 10;
    easing = 0.05;
    easingAI = 0.05;
  }

  resetGame();
}
