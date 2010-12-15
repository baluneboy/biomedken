function phonebook(varargin)

pbname = 'myphonebook'; % name of data dictionary
if ispc
    datadir = char(java.lang.System.getProperty('user.dir'));
else
    datadir = getenv('HOME');
end;
pbname = fullfile(datadir, pbname);

if ~exist(pbname)
    disp(sprintf('Data file %s does not exist.', pbname));
    r = input('Create a new phone book (y/n)?','s');
    if r == 'y',
        try
            FOS = java.io.FileOutputStream(pbname);
            FOS.close
        catch
            error(sprintf('Failed to create %s', pbname));
        end;
    else
        return;
    end;
end;

pb_htable = java.util.Properties;

try
    FIS = java.io.FileInputStream(pbname);
catch
    error(sprintf('Failed to open %s for reading.', pbname));
end;

pb_htable.load(FIS);
FIS.close;

while 1
    disp ' '
    disp ' Phonebook Menu:'
    disp ' '
    disp ' 1. Look up a phone number'
    disp ' 2. Add an entry to the phone book'
    disp ' 3. Remove an entry from the phone book'
    disp ' 4. Change the contents of an entry in the phone book'
    disp ' 5. Display entire contents of the phone book'
    disp ' 6. Exit this program'
    disp ' '
    s = input('Please type the number for a menu selection: ','s');
    switch s
        case '1',
            name = input('Enter the name to look up: ','s');
            if isempty(name)
                disp 'No name entered'
            else
                pb_lookup(pb_htable, name);
            end;
        case '2',
            pb_add(pb_htable);

        case '3',
            name=input('Enter the name of the entry to remove: ', 's');
            if isempty(name)
                disp 'No name entered'
            else
                pb_remove(pb_htable, name);
            end;

        case '4',
            name=input('Enter the name of the entry to change: ', 's');
            if isempty(name)
                disp 'No name entered'
            else
                pb_change(pb_htable, name);
            end;

        case '5',
            pb_listall(pb_htable);

        case '6',
            try
                FOS = java.io.FileOutputStream(pbname);
            catch
                error(sprintf('Failed to open %s for writing.',...
                    pbname));
            end;
            pb_htable.save(FOS,'Data file for phonebook program');
            FOS.close;
            return;
        otherwise
            disp 'That selection is not on the menu.'
    end;
end;

%
function pb_lookup(pb_htable,name)
entry = pb_htable.get(pb_keyfilter(name));
if isempty(entry),
    disp(sprintf('The name %s is not in the phone book',name));
else
    pb_display(entry);
end

%
function pb_add(pb_htable)
disp 'Type the name for the new entry, followed by Enter.'
disp 'Then, type the phone number(s), one per line.'
disp 'To complete the entry, type an extra Enter.'
name = input(':: ','s');
entry=[name '^'];
while 1
    line = input(':: ','s');
    if isempty(line)
        break;
    else
        entry=[entry line '^'];
    end;
end;

if strcmp(entry, '^')
    disp 'No name entered'
    return;
end;

pb_htable.put(pb_keyfilter(name),entry);
disp ' '
disp(sprintf('%s has been added to the phone book.', name));

% Description of Function pb_remove
%
%    1.
%
%       Look for the key in the phone book.
%
%       Arguments passed to pb_remove are the Properties object pb_htable and the name key for the entry to remove. The pb_remove function calls containsKey on pb_htable with the name key, on which support function pb_keyfilter is called to change spaces to underscores. If name is not in the phone book, disp displays a message and the function returns.
function pb_remove(pb_htable,name)
if ~pb_htable.containsKey(pb_keyfilter(name))
    disp(sprintf('The name %s is not in the phone book',name))
    return
end;

%    2.
%
%       Ask for confirmation and if given, remove the key.
%
%       If the key is in the hash table, pb_remove asks for user confirmation. If the user confirms the removal by entering y, pb_remove calls remove on pb_htable with the (filtered) name key, and displays a message that the entry has been removed. If the user enters n, the removal is not performed and disp displays a message that the removal has not been performed.

r = input(sprintf('Remove entry %s (y/n)? ',name), 's');
if r == 'y'
    pb_htable.remove(pb_keyfilter(name));
    disp(sprintf('%s has been removed from the phone book',name))
else
    disp(sprintf('%s has not been removed',name))
end;

% Description of Function pb_change
%
%    1.
%
%       Find the entry to change, and confirm.
%
%       Arguments passed to pb_change are the Properties object pb_htable and the name key for the requested entry. The pb_change function calls get on pb_htable with the name key, on which pb_keyfilter is called to change spaces to underscores. The get method returns the entry (or null, if the entry is not found) to variable entry. pb_change calls isempty to determine whether the entry is empty. If the entry is empty, pb_change displays a message that the name is added to the phone book, and allows the user to enter the phone number(s) for the entry.
%
%       If the entry is found, in the else clause, pb_change calls pb_display to display the entry. It then uses input to ask the user to confirm the replacement. If the user enters anything other than y, the function returns.
function pb_change(pb_htable,name)
entry = pb_htable.get(pb_keyfilter(name));
if isempty(entry)
    disp(sprintf('The name %s is not in the phone book', name));
    return;
else
    pb_display(entry);
    r = input('Replace phone numbers in this entry (y/n)? ','s');
    if r ~= 'y'
        return;
    end;
end;

%    2.
%
%       Input new phone number(s) and change the phone book entry.
%
%       pb_change uses disp to display a prompt for new phone number(s). Then, pb_change inputs data into variable entry, with the same statements described in Description of Function pb_lookup.
%
%       Then, to replace the existing entry with the new one, pb_change calls put on pb_htable with the (filtered) key name and the new entry. It then displays a message that the entry has been changed.
disp 'Type in the new phone number(s), one per line.'
disp 'To complete the entry, type an extra Enter.'
disp(sprintf(':: %s', name));
entry=[name '^'];
while 1
    line = input(':: ','s');
    if isempty(line)
        break;
    else
        entry=[entry line '^'];
    end;
end;
pb_htable.put(pb_keyfilter(name),entry);
disp ' '
disp(sprintf('The entry for %s has been changed', name));

%The pb_listall function takes one argument, the Properties object pb_htable. The function calls propertyNames on the pb_htable object to return to enum a java.util.Enumeration object, which supports convenient enumeration of all the keys. In a while loop, pb_listall calls hasMoreElements on enum, and if it returns true, pb_listall calls nextElement on enum to return the next key. It then calls pb_display to display the key and entry, which it retrieves by calling get on pb_htable with the key.
function pb_listall(pb_htable)
enum = pb_htable.propertyNames;
while enum.hasMoreElements
    key = enum.nextElement;
    pb_display(pb_htable.get(key));
end;

%The pb_display function takes an argument entry, which is a phone book entry. After displaying a horizontal line, pb_display calls MATLAB function strtok to extract the first line of the entry, up to the line delimiter (^), into t and the remainder into r. Then, within a while loop that terminates when t is empty, it displays the current line in t. Then it calls strtok to extract the next line from r, into t. When all lines have been displayed, pb_display indicates the end of the entry by displaying another horizontal line.
function pb_display(entry)
disp ' '
disp '-------------------------'
[t,r] = strtok(entry,'^');
while ~isempty(t)
    disp(sprintf(' %s',t));
    [t,r] = strtok(r,'^');
end;
disp '-------------------------'

%The pb_keyfilter function takes an argument key, which is a name used as a key in the hash table, and either filters it for storage or unfilters it for display. The filter, which replaces each space in the key with an underscore (_), makes the key usable with the methods of java.util.Properties.
function out = pb_keyfilter(key)
if ~isempty(findstr(key,' '))
    out = strrep(key,' ','_');
else
    out = strrep(key,'_',' ');
end;