//
//  DragAndDropArrayController.swift
//  minimalTunes
//
//  Created by John Moody on 7/1/16.
//  Copyright © 2016 John Moody. All rights reserved.
//

import Cocoa

class DragAndDropArrayController: NSArrayController, NSTableViewDataSource, NSTableViewDelegate {
    
    var mainWindow: MainWindowController?
    var tableViewController: LibraryTableViewController?
    var draggedRowIndexes: NSIndexSet?
    
    func tableView(tableView: NSTableView, willDisplayCell cell: AnyObject, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        if tableColumn == tableView.tableColumns[0] {
            if (self.arrangedObjects as! [TrackView])[row].track?.is_playing == true {
                (cell as! NSImageCell).image = NSImage(named: "NSAudioOutputVolumeMedTemplate")
            } else {
                (cell as! NSImageCell).image = nil
            }
        }
    }
    
    
    func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        print("sort descriptors did change called")
        let archivedSortDescriptor = NSKeyedArchiver.archivedDataWithRootObject(tableView.sortDescriptors)
        if tableViewController?.playlist?.track_id_list != nil {
            NSUserDefaults.standardUserDefaults().setObject(archivedSortDescriptor, forKey: DEFAULTS_PLAYLIST_SORT_DESCRIPTOR_STRING)
        } else {
            NSUserDefaults.standardUserDefaults().setObject(archivedSortDescriptor, forKey: DEFAULTS_LIBRARY_SORT_DESCRIPTOR_STRING)
        }
    }
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        print("table view writerows called")
        let rows = NSMutableArray()
        
        for index in rowIndexes {
            let trackView = (self.arrangedObjects as! [TrackView])[index]
            rows.addObject(trackView.track!.objectID.URIRepresentation())
        }
        draggedRowIndexes = rowIndexes
        let encodedIDs = NSKeyedArchiver.archivedDataWithRootObject(rows)
        let context = mainWindow?.currentSourceListItem?.name
        print("context is \(context)")
        if context != nil {
            pboard.setString(context!, forType: "context")
        }
        if mainWindow?.currentSourceListItem?.is_network == true {
            print("settin network pboard data")
            pboard.setData(encodedIDs, forType: "NetworkTrack")
        } else {
            pboard.setData(encodedIDs, forType: "Track")
        }
        return true
    }
    
    func tableView(tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAtPoint screenPoint: NSPoint, forRowIndexes rowIndexes: NSIndexSet) {
        print("dragypoo called")
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        if info.draggingPasteboard().types!.contains(NSFilenamesPboardType) {
            let files = info.draggingPasteboard().propertyListForType(NSFilenamesPboardType) as! NSArray
            let urls = files.map({return NSURL(fileURLWithPath: $0 as! String)})
            let appDelegate = (NSApplication.sharedApplication().delegate as! AppDelegate)
            var errors = [FileAddToDatabaseError]()
            let urlParseResult = appDelegate.getFilesAsURLStringsInURLList(urls)
            errors.appendContentsOf(urlParseResult.1)
            let urlStrings = urlParseResult.0
            let newErrors = appDelegate.addURLStringsToLibrary(urlStrings)
            errors.appendContentsOf(newErrors)
            for error in errors {
                error.urlString = error.urlString.stringByRemovingPercentEncoding!
            }
            appDelegate.showImportErrors(errors)
            return true
        }
        //if we've reached this point, we must be in a playlist with a valid track id list, and the table must be sorted by playlist order
        var track_id_list = tableViewController!.playlist!.track_id_list as! [Int]
        var ids = [Int]()
        for index in draggedRowIndexes!.reverse() {
            ids.append(track_id_list[index])
            track_id_list.removeAtIndex(index)
        }
        ids = ids.reverse()
        track_id_list.insertContentsOf(ids, at: row)
        tableViewController!.playlist!.track_id_list = track_id_list
        tableViewController?.initializeForPlaylist()
        draggedRowIndexes = nil
        return true
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if info.draggingPasteboard().types!.contains(NSFilenamesPboardType) {
            print("doingle")
            tableView.setDropRow(-1, dropOperation: NSTableViewDropOperation.On)
            return .Copy
        }
        if draggedRowIndexes != nil && dropOperation == .Above && tableView.sortDescriptors == [tableView.tableColumns[1].sortDescriptorPrototype!] && tableViewController?.playlist?.smart_criteria == nil {
            return .Move
        } else {
            return .None
        }
    }
}