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


[GtkTemplate (ui = "/com/github/Rirusha/Cassette/ui/action_card_custom.ui")]
/**
    * A class for convenient work with clickable cards.
    */
public class Cassette.ActionCardCustom : Adw.Bin {

    [GtkChild]
    unowned Gtk.Button real_button;
    [GtkChild]
    unowned Adw.Bin content_bin;

    public Gtk.Widget content {
        get {
            return content_bin.child;
        }
        set {
            content_bin.child = value;
        }
    }

    public signal void clicked ();

    public ActionCardCustom.with_content (
        Gtk.Widget content
    ) {
        Object (
            content: content
        );
    }

    construct {
        real_button.clicked.connect (() => {
            clicked ();
        });
    }
}
