/* Copyright 2023-2024 Rirusha
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */

using CassetteClient;
using Gee;

namespace Cassette {
    public interface Initable {
        protected abstract string content_id { get; set; }

        public abstract void init_content (string content_id);
    }

    public enum BlockReason {
        NOT_IMPLEMENTED,
        NEED_ONLINE,
        NEED_PLUS
    }

    public static void block_widget (Gtk.Widget widget, BlockReason reason) {
        if (!application.is_devel) {
            widget.sensitive = false;
        }

        switch (reason) {
            case BlockReason.NOT_IMPLEMENTED:
                widget.tooltip_text = _("Not implemented yet");
                break;
            case BlockReason.NEED_ONLINE:
                widget.tooltip_text = _("Need authorization");
                break;
            case BlockReason.NEED_PLUS:
                widget.tooltip_text = _("Need Plus subscription");
                break;
        }
    }

    public static void roll_shuffle_mode () {
        switch (player.shuffle_mode) {
            case Player.ShuffleMode.OFF:
                player.shuffle_mode = Player.ShuffleMode.ON;
                break;
            case Player.ShuffleMode.ON:
                player.shuffle_mode = Player.ShuffleMode.OFF;
                break;
        }
    }

    public static void roll_repeat_mode () {
        switch (player.repeat_mode) {
            case Player.RepeatMode.OFF:
                player.repeat_mode = Player.RepeatMode.REPEAT_ALL;
                break;
            case Player.RepeatMode.REPEAT_ALL:
                player.repeat_mode = Player.RepeatMode.REPEAT_ONE;
                break;
            case Player.RepeatMode.REPEAT_ONE:
                player.repeat_mode = Player.RepeatMode.OFF;
                break;
        }
    }

    public static void track_share (CassetteClient.YaMAPI.Track track_info) {
        string url = @"https://music.yandex.ru/album/$(track_info.albums[0].id)/track/$(track_info.id)?utm_medium=copy_link";

        Gdk.Display? display = Gdk.Display.get_default ();
        Gdk.Clipboard clipboard = display.get_clipboard ();
        clipboard.set (Type.STRING, url);
        application.show_message (_("Link copied to clipboard"));
    }

    public static void playlist_share (CassetteClient.YaMAPI.Playlist playlist_info) {
        string url = @"https://music.yandex.ru/users/$(playlist_info.owner.login)/playlists/$(playlist_info.kind)?utm_medium=copy_link";

        Gdk.Display? display = Gdk.Display.get_default ();
        Gdk.Clipboard clipboard = display.get_clipboard ();
        clipboard.set (Type.STRING, url);
        application.show_message (_("Link copied to clipboard"));
    }

    public static async void show_track_by_id (string track_id) {
        threader.add (() => {
            var track_infos = yam_talker.get_tracks_info ({track_id});

            if (track_infos != null) {
                application.main_window.sidebar.show_track_info (track_infos[0]);
            }

            Idle.add (show_track_by_id.callback);
        });

        yield;
    }

    public static int ms2sec (int ms) {
        return ms / 1000;
    }

    public static string sec2str (int seconds, bool is_short) {
        int minutes = (int) seconds / 60;
        int oth_seconds = (seconds - minutes * 60);

        string minutes_str = minutes.to_string ();
        string oth_seconds_str = oth_seconds.to_string ();

        if (is_short) {
            return @"$minutes_str:$(zfill (oth_seconds_str, 2))";
        } else {

            if (minutes > 60) {
                int hours = (int) minutes / 60;
                minutes -= hours * 60;

                string hours_str = hours.to_string ();
                minutes_str = minutes.to_string ();
                return _("Duration: %s h. %s min.").printf (hours_str, minutes_str);
            }
            return _("Duration: %s min.").printf (minutes_str);
        }
    }

    public static string ms2str (int ms, bool is_short) {
        int seconds = ms2sec (ms);
        return sec2str (seconds, is_short);
    }

    //  ("111", 6) -> "000111"
    public static string zfill (string str, int width) {
        if (str.length >= width) {
            return str;
        } else {
            int padding = width - str.length;
            return string.nfill (padding, '0') + str;
        }
    }

    // (1, 6, 1) -> {1, 2, 3, 4, 5}
    public static HashSet<int> range_set (int start, int end, int step = 1) {
        var rng = new HashSet<int> ();
        for (int item = start; item < end; item += step) {
            rng.add (item);
        }
        return rng;
    }

    // set_1 - set_2
    public static HashSet<int> difference (HashSet<int> set_1, HashSet<int> set_2) {
        var out_set = new HashSet<int> ();
        foreach (int el in set_1) {
            if (!(el in set_2)) {
                out_set.add (el);
            }
        }
        return out_set;
    }

    //  [2:23.24] -> 143240
    public static int64 parse_time (owned string time_str) {
        time_str.strip ();
        time_str = time_str[1:time_str.length - 1];

        string[] data_min_secms = time_str.split (":");
        string[] data_sec_ms = data_min_secms[1].split (".");

        int64 mins_ms = int64.parse (data_min_secms[0], 10) * 60000;
        int64 secs_ms = int64.parse (data_sec_ms[0], 10) * 1000;
        int64 pure_ms = int64.parse (data_sec_ms[1], 10) * 10;

        return mins_ms + secs_ms + pure_ms;
    }

    public static string get_when (string iso8601_datetime_str) {
        var dt = new DateTime.from_iso8601 (iso8601_datetime_str, null);
        var now_dt = new DateTime.now ();

        var days = (int) (now_dt.difference (dt) / TimeSpan.DAY);

        if (days < 1) {
            return _("today");
        } else if (days < 2) {
            return _("yesterday");
        } else {
            return dt.format ("%x").replace ("/", ".");
        }
    }

    public static string prettify_num (int num) {
        string num_str = num.to_string ();

        return prettify_chunk (num_str, num_str.length - 3, "");
    }

    static string prettify_chunk (string num_str, int start_pos, string res_str) {
        if (start_pos == -3) {
            return res_str;
        }

        int end_pos = start_pos + 3;

        if (start_pos < 0) {
            start_pos = 0;
        }

        return prettify_chunk (num_str, start_pos - 3, num_str[start_pos:end_pos] + " " + res_str);
    }

    static double min (double a, double b) {
        return a < b ? a : b;
    }

    static double max (double a, double b) {
        return a > b ? a : b;
    }
}
