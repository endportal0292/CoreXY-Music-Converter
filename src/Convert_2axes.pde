void convert2axes() {
  if (str_number == inp.length || inp[str_number].equals("M02")) {    //end of the file
    if (wait_before_start_g4 != 0) out += "G4 P" + str(wait_before_start_g4);  //g4
    if (use_m84) out += "\n" + "M84";    //m84
    convert = false;
    convert_is_end = true;
    use_m84_last = use_m84;
    wait_before_start_g4_last = wait_before_start_g4;
    accel_last = accel;
    gcode_type_last = gcode_type;
    save_tmr = millis() - 5010;
    copy_tmr = millis() - 5010;
    return;   //convert finish
  }

  if (inp[str_number].indexOf("X") == -1 || inp[str_number].indexOf("Y") == -1 || inp[str_number].indexOf("F") == -1) {
    convert = false;            //string does not contain one of the gcode parameters
    convert_is_end = false;
    file_error = str_number + 1; //syntax error
    return;    // stop
  }

  int Xpos = inp[str_number].indexOf("X");    //load gcode parameters
  int Ypos = inp[str_number].indexOf("Y");
  int Fpos = inp[str_number].indexOf("F");
  double Xread = Double.parseDouble(inp[str_number].substring(Xpos + 1, inp[str_number].indexOf(" ", Xpos)));
  double Yread = Double.parseDouble(inp[str_number].substring(Ypos + 1, inp[str_number].indexOf(" ", Ypos)));
  double Fread = Double.parseDouble(inp[str_number].substring(Fpos + 1, inp[str_number].length() - 1));
  double Xabs = Math.abs(Xread - Xlast);
  double Yabs = Math.abs(Yread - Ylast);

  if (Xabs < 0.00000001 && Yabs < 0.00000001) {     //small change in coordinates
    BigDecimal Xnumber = new BigDecimal(Xaxis).setScale(8, RoundingMode.HALF_UP);
    BigDecimal Ynumber = new BigDecimal(Yaxis).setScale(8, RoundingMode.HALF_UP);
    out += "G1 X" + Xnumber + " Y" + Ynumber + " F" + Fread + "\n";
    str_number++;    //next line
  } else {

    double time = Math.hypot(Xabs, Yabs) / (Fread / 60.0);  //time of movement

    if (motors_swapped) {     //motors(axis) swapped
      double t = Xabs;
      Xabs = Yabs;
      Yabs = t;
    }

    double Xrel_new = 0.5 * (Xabs + Yabs) * (Xinv ? -1.0 : 1.0);     //new travel distance
    double Yrel_new = 0.5 * Math.abs(Yabs - Xabs) * (Yinv ? -1.0 : 1.0);

    if (Xaxis + Xrel_new > Xmax || Xaxis + Xrel_new < Xmin) {  //rebound from the wall along the x coordinate
      double t = Xabs;   //swap motors(axis)
      Xabs = Yabs;
      Yabs = t;
      motors_swapped = !motors_swapped;
      Xinv = !Xinv;     //inverting the direction of movement of the x coordinate
      Xrel_new = 0.5 * (Xabs + Yabs) * (Xinv ? -1.0 : 1.0);
      Yrel_new = 0.5 * Math.abs(Yabs - Xabs) * (Yinv ? -1.0 : 1.0);

      if (Yaxis + Yrel_new > Ymax || Yaxis + Yrel_new < Ymin) {  //rebound from the wall along the y coordinate
        t = Xabs;   //swap motors(axis)
        Xabs = Yabs;
        Yabs = t;
        motors_swapped = !motors_swapped;
        Yinv = !Yinv;       //inverting the direction of movement of the y coordinate
        Xrel_new = 0.5 * (Xabs + Yabs) * (Xinv ? -1.0 : 1.0);
        Yrel_new = 0.5 * Math.abs(Yabs - Xabs) * (Yinv ? -1.0 : 1.0);
      }
    } else if (Yaxis + Yrel_new > Ymax || Yaxis + Yrel_new < Ymin) {  //rebound from the wall along the y coordinate
      double t = Xabs;   //swap motors(axis)
      Xabs = Yabs;
      Yabs = t;
      motors_swapped = !motors_swapped;
      Yinv = !Yinv;       //inverting the direction of movement of the y coordinate
      Xrel_new = 0.5 * (Xabs + Yabs) * (Xinv ? -1.0 : 1.0);
      Yrel_new = 0.5 * Math.abs(Yabs - Xabs) * (Yinv ? -1.0 : 1.0);

      if (Xaxis + Xrel_new > Xmax || Xaxis + Xrel_new < Xmin) {  //rebound from the wall along the x coordinate
        t = Xabs;   //swap motors(axis)
        Xabs = Yabs;
        Yabs = t;
        motors_swapped = !motors_swapped;
        Xinv = !Xinv;       //inverting the direction of movement of the x coordinate
        Xrel_new = 0.5 * (Xabs + Yabs) * (Xinv ? -1.0 : 1.0);
        Yrel_new = 0.5 * Math.abs(Yabs - Xabs) * (Yinv ? -1.0 : 1.0);
      }
    }

    Xaxis += Xrel_new;    //new coords
    Yaxis += Yrel_new;
    double Fnew = Math.hypot(Math.abs(Xrel_new), Math.abs(Yrel_new)) / time * 60.0;   //new speed of movement

    BigDecimal Xnumber = new BigDecimal(Xaxis).setScale(8, RoundingMode.HALF_UP);  //rounding axis
    BigDecimal Ynumber = new BigDecimal(Yaxis).setScale(8, RoundingMode.HALF_UP);
    BigDecimal Fnumber = new BigDecimal(Fnew).setScale(8, RoundingMode.HALF_UP);


    out += "G1 X" + Xnumber + " Y" + Ynumber + " F" + Fnumber + "\n";    //write to file
    Xlast = Xread;
    Ylast = Yread;
    str_number++;    //next line
  }
}
