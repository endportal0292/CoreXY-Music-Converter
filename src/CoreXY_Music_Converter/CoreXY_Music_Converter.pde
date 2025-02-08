import java.awt.*;
import java.awt.datatransfer.*;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.io.File.*;
import java.nio.file.*;

/*
  Code to convert musical gcode cartesian coordinate system to gcode corexy coordinate system.
 The author is not responsible for any possible damage to the CNC when using this program!
 v1.0
 */

Text txt_ac = new Text();
Text txt_g4 = new Text();

PImage save_icon;
PImage open_icon;

float ksz;                                         //TOO many variables, I know, maybe I'll fix it later
boolean allfl;
String inp[];
String out = "";
String name = "";
int axes = 0;
double steps_per_mmX = 0;
double steps_per_mmY = 0;
double steps_per_mmZ = 0;
boolean spmX_is_int = true;
boolean spmY_is_int = true;
boolean spmZ_is_int = true;
boolean Xmin_is_int = true;
boolean Ymin_is_int = true;
boolean Zmin_is_int = true;
boolean Xmax_is_int = true;
boolean Ymax_is_int = true;
boolean Zmax_is_int = true;
boolean use_m84 = true;
boolean use_m84_last = true;
boolean convert = false;
boolean convert_is_end = false;
boolean need_save = false;
boolean save_icon_exists = false;
boolean open_icon_exists = false;
boolean gcode_type = true;
boolean gcode_type_last = true;
float save_rads = 0;
int file_error = 0;
long error_tmr = 0;
long conv_tmr = 0;
long copy_tmr = 0;
long save_tmr = 0;
long need_save_tmr = 0;
long save_show_tmr = 0;
int str_number = 0;
double Xlast = 0;
double Ylast = 0;
double Xaxis = 0;
double Yaxis = 0;
double Zaxis = 0;
boolean Xinv = false;
boolean Yinv = false;
boolean motors_swapped = false;
int wait_before_start_g4 = 5000;
int wait_before_start_g4_last = 5000;
int accel = 4000;
int accel_last = 4000;
double Xmin = 0;
double Xmax = 0;
double Ymin = 0;
double Ymax = 0;
double Zmin = 0;
double Zmax = 0;                                          //really a lot




void settings() {
  ksz = displayHeight / 1080.0;
  size(int(1600 * ksz), int(800 * ksz));
  smooth(2);
}


void setup() {
  surface.setTitle("CoreXY Music Converter");
  File ico = new File(dataPath("icon.png").replace("\\", "/"));
  if (ico.exists()) surface.setIcon(loadImage("icon.png"));
  frameRate(10000);
  textFont(createFont("Arial", 30, true));
  textAlign(CENTER, CENTER);
  imageMode(CENTER);
  rectMode(CENTER);
  loadData();
  copy_tmr = -5000;
  save_tmr = -5000;
  save_show_tmr = -2000;
}




void draw() {
  if (!convert) {
    background(215);    //background, surprisingly



    //******************Saving***********************

    stroke(150);
    strokeWeight(10 * ksz);
    line(width / 2, 0, width / 2, height);
    if (accel != accel_last || use_m84 != use_m84_last || wait_before_start_g4 != wait_before_start_g4_last || gcode_type != gcode_type_last) {
      convert_is_end = false;
      use_m84_last = use_m84;
      wait_before_start_g4_last = wait_before_start_g4;
      accel_last = accel;
      gcode_type_last = gcode_type;
      need_save = true;
      need_save_tmr = millis();
    }

    if (need_save && millis() - need_save_tmr >= 5000) {
      PrintWriter output;
      output = createWriter("data/settings.txt");
      output.print(str(accel) + "," + str(use_m84) + "," + str(wait_before_start_g4) + "," + str(gcode_type));
      output.flush();
      output.close();
      need_save = false;
      save_show_tmr = millis();
      save_rads = 0;
    }

    if (millis() - save_show_tmr <= 2000) {
      pushMatrix();
      translate(850 * ksz, 754 * ksz);
      pushStyle();
      textAlign(LEFT, CENTER);
      textSize(50 * ksz);
      text("Saving...", save_icon_exists ? 50 * ksz : -30 * ksz, 0);
      if (save_icon_exists) {
        rotate(save_rads);
        image(save_icon, 0, 0);
        save_rads += radians(1);
      }
      popStyle();
      popMatrix();
    }

    //******************Saving***********************





    //*********************************Convert button**************************************

    if (rectButton(400 * ksz, 750 * ksz, 350 * ksz, 60 * ksz, 15 * ksz, #00FF00, #62FF6B, 0, 0, convert_is_end ? "Converted" : "Convert", 50 * ksz, 0, axes >= 2 && !convert && !convert_is_end) && !allfl) {
      allfl = true;
      convert = true;
      convert_is_end = false;
      if (axes == 3) str_number = 22;
      else str_number = 20;
      Xaxis = Xmin;
      Yaxis = Ymin;
      Zaxis = Zmin;
      Xlast = Xmin;
      Ylast = Ymin;
      Xinv = false;
      Yinv = false;
      motors_swapped = false;
      out = "";
      out += "G28\n";
      out += "G90\n";
      out += "G21\n";
      out += gcode_type ? "SET_VELOCITY_LIMIT ACCEL=500 ACCEL_TO_DECEL=500\n" : "M204 T500\n";
      out += "G1 Z" + Zmin + " F600\n";
      out += "G1 X" + Xmin + " Y" + Ymin + " F7800\n";
      out += gcode_type ? ("SET_VELOCITY_LIMIT ACCEL=" + accel + " ACCEL_TO_DECEL=" + accel + "\n") : ("M204 T" + accel + "\n");
      if (wait_before_start_g4 != 0) out += "G4 P" + wait_before_start_g4 + "\n";
    }
    //*********************************Convert button**************************************




    //*********************************Open button************************************

    if (rectButton(745 * ksz, 50 * ksz, 75 * ksz, 75 * ksz, 15 * ksz, #0075FF, #4399FF, 0, 150, open_icon_exists ? "" : "...", 40 * ksz, 0, !convert) && !allfl) {
      allfl = true;
      mousePressed = false;
      selectInput("Select source file(*.gcode, *.nc, *.txt)", "fileSelected");
    }
    if (open_icon_exists) image(open_icon, 745 * ksz, 50 * ksz);
    //*********************************Open button************************************




    //*********************************Copy button*******************************

    if (rectButton(1004 * ksz, 50 * ksz, 340 * ksz, 70 * ksz, 10 * ksz, #00FF00, #62FF6B, 0, 150, millis() - copy_tmr <= 5000 && !convert ? "Copied" : "Copy", 50 * ksz, 0, convert_is_end) && !allfl) {
      allfl = true;
      String selection = out;
      StringSelection data = new StringSelection(selection);
      Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
      clipboard.setContents(data, data);
      copy_tmr = millis();
    }
    //*********************************Copy button*******************************





    //*********************************Save button*******************************

    if (rectButton(1402 * ksz, 50 * ksz, 340 * ksz, 70 * ksz, 10 * ksz, #0075FF, #4399FF, 0, 150, millis() - save_tmr <= 5000 && !convert ? "Saved" : "Save", 50 * ksz, 0, convert_is_end) && !allfl) {
      allfl = true;
      PrintWriter output;
      output = createWriter("out/" + name + " - CoreXY - " + (gcode_type ? "Klipper" : "Marlin") + ".gcode");
      output.print(out);
      output.flush();
      output.close();
      save_tmr = millis();
    }
    //*********************************Save button*******************************






    //*********************************Gcode type button*****************************

    if (rectButton(1320 * ksz, 138 * ksz, 155 * ksz, 52 * ksz, 5 * ksz, #0075FF, #4399FF, 0, 0, gcode_type ? "Klipper" : "Marlin", 45 * ksz, 0, !convert) && !allfl) {
      allfl = true;
      gcode_type = !gcode_type;
    }
    //*********************************Gcode type button*****************************




    //********************************* UI *******************************************

    stroke(150);
    strokeWeight(5 * ksz);
    fill(255);
    rect(350 * ksz, 62 * ksz, 670 * ksz, 100 * ksz, 10 * ksz); //file name rect

    textSize(35 * ksz);
    fill(0);
    textAlign(LEFT, TOP);
    text(name, 355 * ksz, 62 * ksz, 660 * ksz, 100 * ksz); //file name text

    fill(255);
    strokeWeight(3 * ksz);
    rect(400 * ksz, 450 * ksz, 700 * ksz, 500 * ksz, 5 * ksz); //file data rect
    strokeWeight(2 * ksz);
    line(400 * ksz, 200 * ksz, 400 * ksz, 700 * ksz);
    line(50 * ksz, 300 * ksz, 750 * ksz, 300 * ksz);

    textAlign(CENTER, CENTER);
    fill(file_error == 0 ? 0 : #FF0000); // number of axes/file error
    text(file_error == 0 ? ("Number of axes: " + axes) : file_error == 1 ? "File does not match syntax!" : ("Syntax error on line " + file_error + "!"), 400 * ksz, 150 * ksz);
    fill(0);
    text("Steps per millimeter", 225 * ksz, 245 * ksz);
    text("Work area in\nmillimeters", 575 * ksz, 245 * ksz);

    line(50 * ksz, 433 * ksz, 750 * ksz, 433 * ksz); //file data rect lines
    line(50 * ksz, 566 * ksz, 750 * ksz, 566 * ksz);

    textAlign(LEFT, CENTER); //steps per mm
    text("X axis: " + (spmX_is_int ? new BigDecimal(steps_per_mmX).setScale(0, RoundingMode.HALF_UP) : steps_per_mmX), 130 * ksz, 360 * ksz);
    text("Y axis: " + (spmY_is_int ? new BigDecimal(steps_per_mmY).setScale(0, RoundingMode.HALF_UP) : steps_per_mmY), 130 * ksz, 493 * ksz);
    text("Z axis: " + (spmZ_is_int ? new BigDecimal(steps_per_mmZ).setScale(0, RoundingMode.HALF_UP) : steps_per_mmZ), 130 * ksz, 626 * ksz);

    //min and max zones
    text("Xmin: " + (Xmin_is_int ? new BigDecimal(Xmin).setScale(0, RoundingMode.HALF_UP) : Xmin), 430 * ksz, 335 * ksz);
    text("Xmax: " + (Xmax_is_int ? new BigDecimal(Xmax).setScale(0, RoundingMode.HALF_UP) : Xmax), 430 * ksz, 385 * ksz);
    text("Ymin: " + (Ymin_is_int ? new BigDecimal(Ymin).setScale(0, RoundingMode.HALF_UP) : Ymin), 430 * ksz, 468 * ksz);
    text("Ymax: " + (Ymax_is_int ? new BigDecimal(Ymax).setScale(0, RoundingMode.HALF_UP) : Ymax), 430 * ksz, 518 * ksz);
    text("Zmin: " + (Zmin_is_int ? new BigDecimal(Zmin).setScale(0, RoundingMode.HALF_UP) : Zmin), 430 * ksz, 601 * ksz);
    text("Zmax: " + (Zmax_is_int ? new BigDecimal(Zmax).setScale(0, RoundingMode.HALF_UP) : Zmax), 430 * ksz, 651 * ksz);


    textAlign(CENTER, CENTER);
    textSize(50 * ksz);
    text("Settings for", 1100 * ksz, 130 * ksz); //text before gcode type button

    fill(255);
    strokeWeight(3 * ksz);
    rect(1200 * ksz, 450 * ksz, 700 * ksz, 500 * ksz, 5 * ksz); //settings rect
    strokeWeight(2 * ksz);
    line(1083 * ksz, 200 * ksz, 1083 * ksz, 700 * ksz);
    line(1317 * ksz, 200 * ksz, 1317 * ksz, 700 * ksz);
    line(850 * ksz, 300 * ksz, 1550 * ksz, 300 * ksz);

    textSize(35 * ksz);
    fill(0); //settings names
    text("Acceleration\nof movement", 968 * ksz, 245 * ksz);
    text("Turn off the\nmotors(M84)", 1201 * ksz, 245 * ksz);
    text("Wait before\nstarting(G4)", 1435 * ksz, 245 * ksz);

    //********************************* UI *******************************************




    /*********************Acceleration of movement*********************/
    accel = int(txt_ac.update(917 * ksz, 340 * ksz, 104 * ksz, 40 * ksz, 3 * ksz, 120, 30 * ksz, str(accel), 255, 0, !convert, 230));
    if (accel == 0) {
      accel = 2000;
      if (!txt_ac.op && txt_ac.out.equals("0")) {
        txt_ac.out = "2000";
        txt_ac.crs = 4;
      }
    }
    textSize(30 * ksz);
    text("mm/s", 1017 * ksz, 340 * ksz);
    textSize(17 * ksz);
    text("2", 1057 * ksz, 330 * ksz);

    pushStyle();
    textAlign(LEFT, TOP);
    textSize(20 * ksz);
    text("High acceleration allows\nfor a clearer sound. If\nacceleration is too high,\nthe printer may produce\nclicking noises and\nchange the sound due\nto the INPUT SHAPING\nalgorithm.", 857 * ksz, 420 * ksz);
    popStyle();
    /*********************Acceleration of movement*********************/




    /*********************Turn off motors*********************/
    textSize(25 * ksz);
    textAlign(LEFT, CENTER);
    text("Yes, turn off", 1115 * ksz, 330 * ksz);
    text("No, don't turn off", 1115 * ksz, 360 * ksz);

    if (circleButton(1100 * ksz, 332 * ksz, 18 * ksz, use_m84 ? #0075FF : 255, 3 * ksz, 195, "", 1, 0, !convert, use_m84 ? #1C88FF : 230) && !allfl) {
      allfl = true;
      use_m84 = true;
    }

    if (circleButton(1100 * ksz, 362 * ksz, 18 * ksz, !use_m84 ? #0075FF : 255, 3 * ksz, 195, "", 1, 0, !convert, !use_m84 ? #1C88FF : 230) && !allfl) {
      allfl = true;
      use_m84 = false;
    }

    pushStyle();
    textAlign(LEFT, TOP);
    textSize(20 * ksz);
    text("The M84 command will\nturn off the motors after\nthe music has finished\nplaying. Turning off the\nmotors allows the drivers\nand motors to cool down.", 1090 * ksz, 420 * ksz);
    popStyle();
    /*********************Turn off motors*********************/




    /*********************Wait before starting*********************/
    wait_before_start_g4 = int(txt_g4.update(1384 * ksz, 340 * ksz, 104 * ksz, 40 * ksz, 3 * ksz, 120, 30 * ksz, str(wait_before_start_g4), 255, 0, !convert, 230));
    textAlign(CENTER, CENTER);
    textSize(30 * ksz);
    text("ms", 1464 * ksz, 340 * ksz);

    pushStyle();
    textAlign(LEFT, TOP);
    textSize(20 * ksz);
    text("The G4 command will\nwait a set amount of time\nbefore and after the\nmusic starts playing.\nThis command makes\nthe music sound cleaner\nat the beginning and end.", 1323 * ksz, 420 * ksz);
    popStyle();
    /*********************Wait before starting*********************/

    textSize(50 * ksz);
    textAlign(RIGHT, BOTTOM);
    text("v1.0", width * 0.99, height * 0.99);    //version
  } else {





    if (axes == 2) {          /*****************CONVERT*****************/
      if (str_number == 20) {
        noStroke();
        fill(215);
        rect(960 * ksz, 754 * ksz, 300 * ksz, 85 * ksz); //delete save icon
        fill(#4FFF4F);
        rect(400 * ksz, 750 * ksz, 350 * ksz, 60 * ksz, 15 * ksz); //redraw convert button without text
        textSize(50 * ksz);
        textAlign(CENTER, CENTER);
      } else if (millis() - conv_tmr >= 25) {
        fill(#4FFF4F);
        rect(400 * ksz, 750 * ksz, 100 * ksz, 40 * ksz); // rect for convert button
        conv_tmr = millis();
        fill(0); //percents
        text(round(((float)(str_number - 20) / (inp.length - 20)) * 100.0) + "%", 400 * ksz, (750 - 60 * 0.1) * ksz);
      }
      convert2axes();
    } else {
      if (str_number == 22) {
        noStroke();
        fill(215);
        rect(960 * ksz, 754 * ksz, 300 * ksz, 85 * ksz); //delete save icon
        fill(#4FFF4F);
        rect(400 * ksz, 750 * ksz, 350 * ksz, 60 * ksz, 15 * ksz); //redraw convert button without text
        textSize(50 * ksz);
        textAlign(CENTER, CENTER);
      } else if (millis() - conv_tmr >= 25) {
        fill(#4FFF4F);
        rect(400 * ksz, 750 * ksz, 100 * ksz, 40 * ksz); // rect for convert button
        conv_tmr = millis();
        fill(0); //percents
        text(round(((float)(str_number - 22) / (inp.length - 22)) * 100.0) + "%", 400 * ksz, (750 - 60 * 0.1) * ksz);
      }
      convert3axes();
    }
  }
}

void fileSelected(File selection) {
  allfl = false;
  if (selection != null) {
    String pth = selection.getAbsolutePath().replace("\\", "/");
    if (pth.substring(pth.length() - 5, pth.length()).equals("gcode") || pth.substring(pth.length() - 2, pth.length()).equals("nc") || pth.substring(pth.length() - 3, pth.length()).equals("txt")) { //type file
      convert_is_end = false;
      inp = loadStrings(pth);
      if (inp.length < 22 || inp[8].length() < 20) file_error = 1; //file too short
      else {
        save_tmr = millis() - 5010;
        copy_tmr = millis() - 5010;
        name = pth.substring(pth.lastIndexOf("/") + 1, pth.lastIndexOf("."));   //get file name
        if (inp[18].equals("G21")) { //file contains gcode
          if ((inp[9].charAt(27) != 'X') || (inp[11].charAt(27) != 'Y') || (inp[13].charAt(27) != 'Z') || !(inp[21].substring(0, 3).equals("G00")) && !(inp[22].substring(0, 3).equals("G01"))) { //incorrect syntax
            steps_per_mmX = 0;
            steps_per_mmY = 0;
            steps_per_mmZ = 0;
            Xmin = 0;
            Xmax = 0;
            Ymin = 0;
            Ymax = 0;
            Zmin = 0;
            Zmax = 0;
            spmX_is_int = true;
            spmY_is_int = true;
            spmZ_is_int = true;
            Xmin_is_int = true;
            Ymin_is_int = true;
            Zmin_is_int = true;
            Xmax_is_int = true;
            Ymax_is_int = true;
            Zmax_is_int = true;
            file_error = 1;      //error
            return;
          }
          axes = 3;
          steps_per_mmX = float(inp[9].substring(35, inp[9].lastIndexOf(")") - 1));       //load data from file
          steps_per_mmY = float(inp[11].substring(35, inp[11].lastIndexOf(")") - 1));
          steps_per_mmZ = float(inp[13].substring(35, inp[13].lastIndexOf(")") - 1));
          Xmin = int(inp[10].substring(28, inp[10].indexOf(" ", 28)));
          Xmax = int(inp[10].substring(inp[10].indexOf("to") + 3, inp[10].lastIndexOf(" ")));
          Ymin = int(inp[12].substring(28, inp[12].indexOf(" ", 28)));
          Ymax = int(inp[12].substring(inp[12].indexOf("to") + 3, inp[12].lastIndexOf(" ")));
          Zmin = int(inp[14].substring(28, inp[14].indexOf(" ", 28)));
          Zmax = int(inp[14].substring(inp[14].indexOf("to") + 3, inp[14].lastIndexOf(" ")));
          file_error = 0;
        } else if (inp[16].equals("G21")) { //file contains gcode
          if ((inp[9].charAt(27) != 'X') || (inp[11].charAt(27) != 'Y') || !(inp[19].substring(0, 3).equals("G00")) && !(inp[20].substring(0, 3).equals("G01"))) { //incorrect syntax
            steps_per_mmX = 0;
            steps_per_mmY = 0;
            steps_per_mmZ = 0;
            Xmin = 0;
            Xmax = 0;
            Ymin = 0;
            Ymax = 0;
            Zmin = 0;
            Zmax = 0;
            spmX_is_int = true;
            spmY_is_int = true;
            spmZ_is_int = true;
            Xmin_is_int = true;
            Ymin_is_int = true;
            Zmin_is_int = true;
            Xmax_is_int = true;
            Ymax_is_int = true;
            Zmax_is_int = true;
            file_error = 1;     //error
            return;
          }
          axes = 2;
          steps_per_mmX = float(inp[9].substring(35, inp[9].lastIndexOf(")") - 1));    //load data from file
          steps_per_mmY = float(inp[11].substring(35, inp[11].lastIndexOf(")") - 1));
          Xmin = int(inp[10].substring(28, inp[10].indexOf(" ", 28)));
          Xmax = int(inp[10].substring(inp[10].indexOf("to") + 3, inp[10].lastIndexOf(" ")));
          Ymin = int(inp[12].substring(28, inp[12].indexOf(" ", 28)));
          Ymax = int(inp[12].substring(inp[12].indexOf("to") + 3, inp[12].lastIndexOf(" ")));
          steps_per_mmZ = 0;
          Zmin = 10;
          Zmax = 10;
          file_error = 0;
        } else {             //incorrect file
          steps_per_mmX = 0;
          steps_per_mmY = 0;
          steps_per_mmZ = 0;
          Xmin = 0;
          Xmax = 0;
          Ymin = 0;
          Ymax = 0;
          Zmin = 0;
          Zmax = 0;
          spmX_is_int = true;
          spmY_is_int = true;
          spmZ_is_int = true;
          Xmin_is_int = true;
          Ymin_is_int = true;
          Zmin_is_int = true;
          Xmax_is_int = true;
          Ymax_is_int = true;
          Zmax_is_int = true;
          file_error = 1;
        }
      }
    }
    spmX_is_int = steps_per_mmX % 1 == 0;    //too many variables to display variables correctly
    spmY_is_int = steps_per_mmY % 1 == 0;
    spmZ_is_int = steps_per_mmZ % 1 == 0;
    Xmin_is_int = Xmin % 1 == 0;
    Ymin_is_int = Ymin % 1 == 0;
    Zmin_is_int = Zmin % 1 == 0;
    Xmax_is_int = Xmax % 1 == 0;
    Ymax_is_int = Ymax % 1 == 0;
    Zmax_is_int = Zmax % 1 == 0;
  }
}

void loadData() {
  File setts = new File(dataPath("settings.txt").replace("\\", "/"));
  if (setts.exists() && loadStrings("settings.txt")[0].split(",").length == 4) { //file exists and contains 4 substrings
    String data[] = loadStrings("settings.txt")[0].split(",");     //load data
    accel = int(data[0]);
    use_m84 = boolean(data[1]);
    wait_before_start_g4 = int(data[2]);
    gcode_type = boolean(data[3]);
    use_m84_last = use_m84;
    wait_before_start_g4_last = wait_before_start_g4;
    accel_last = accel;
    gcode_type_last = gcode_type;
  } else {   //file don't exists or contains not 4 substrings
    PrintWriter output;       //write data
    output = createWriter("data/settings.txt");
    output.print(str(accel) + "," + str(use_m84) + "," + str(wait_before_start_g4) + "," + str(gcode_type));
    output.flush();
    output.close();
  }
  File save_ico = new File(dataPath("save.png").replace("\\", "/"));
  if (save_ico.exists()) {            //save icon exists
    save_icon = loadImage("save.png");      //load save icon
    save_icon.resize(int(60 * ksz), int(60 * ksz));
    save_icon_exists = true;
  } else save_icon_exists = false;

  File open_ico = new File(dataPath("open.png").replace("\\", "/"));
  if (open_ico.exists()) {            //open icon exists
    open_icon = loadImage("open.png");      //open save icon
    open_icon.resize(int(55 * ksz), int(55 * ksz));
    open_icon_exists = true;
  } else open_icon_exists = false;
}
