final int SCALE = 0;
final int LEFT_SWITCH = 1;
final int RIGHT_SWITCH = 2;

final int MATCH_LENGTH = 150;
final int COUNTDOWN_LENGTH = 0;

final short CATEGORY_ROBOT = 0x0001;
final short CATEGORY_CUBE_NORMAL = 0x002;
final short CATEGORY_CUBE_SCALE = 0x004;
final short CATEGORY_SCALE_BORDER = 0x008;
final short CATEGORY_ROBOT_ELEVATOR = 0x010;

final short MASK_ROBOT = CATEGORY_ROBOT | CATEGORY_ROBOT_ELEVATOR | CATEGORY_CUBE_NORMAL;
final short MASK_ROBOT_ELEVATOR = CATEGORY_ROBOT | CATEGORY_ROBOT_ELEVATOR | CATEGORY_CUBE_NORMAL | CATEGORY_SCALE_BORDER;
final short MASK_CUBE_NORMAL = CATEGORY_ROBOT | CATEGORY_ROBOT_ELEVATOR | CATEGORY_CUBE_NORMAL;
final short MASK_CUBE_SCALE = CATEGORY_CUBE_SCALE | CATEGORY_SCALE_BORDER;
final short MASK_SCALE_BORDER = CATEGORY_CUBE_SCALE | CATEGORY_ROBOT_ELEVATOR;