camera_data = {
    camera_id: -1,
    target_id: noone,

    base: {
        width: display_get_gui_width(),
        height: display_get_gui_height()
    },

    zoom: {
        current: 1,
        target: 1,
        minimum: 1,
        maximum: 1.1,
        step: 0.02,
        smoothing: 0.15
    },

    shake: {
        magnitude: 0,
        time: 0,
        duration: 0
    }
};

var _view_w = camera_data.base.width * camera_data.zoom.current;
var _view_h = camera_data.base.height * camera_data.zoom.current;
var _view_x = room_width * 0.5 - _view_w * 0.5;
var _view_y = room_height * 0.5 - _view_h * 0.5;

camera_data.camera_id = camera_create_view(_view_x, _view_y, _view_w, _view_h, 0, noone, -1, -1, -1, -1);

view_enabled = true;
view_set_visible(0, true);
view_set_camera(0, camera_data.camera_id);
view_set_wport(0, camera_data.base.width);
view_set_hport(0, camera_data.base.height);