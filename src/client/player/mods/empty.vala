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
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-only
 */


using Gee;

public class Cassette.Client.Player.Empty : Mode {

    public Empty (Player player) {
        Object (player: player);
    }

    construct {
        player.queue_changed (
            new Gee.ArrayList<YaMAPI.Track> (),
            "various",
            null,
            -1,
            null
        );
    }

    public override int get_prev_index () {
        return -1;
    }

    public override int get_next_index (bool consider_replay_mode) {
        return -1;
    }

    protected override YaMAPI.Play form_play_obj () {
        assert_not_reached ();
    }

    public override async void send_play_async (
        string play_id,
        double end_position_seconds = 0.0,
        double total_played_seconds = 0.0
    ) { }
}
