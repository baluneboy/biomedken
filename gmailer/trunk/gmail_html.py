#!/usr/bin/env python

# Engr > htmlFromClipboard
# Parse html from clipboard
# Paste to Engr section

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from body_html import html

# Gmail user & recipient
gmailUser = 'thehitma@gmail.com'
gmailPassword = 'lmiagmc!'
recipient = 'leftbent@gmail.com'

# Create message container - the correct MIME type is multipart/alternative.
msg = MIMEMultipart('alternative')
msg['Subject'] = "Meeting Agenda, Priorities, Obstacles & Time Estimates"
msg['From'] = gmailUser
msg['To'] = recipient

# Create the body of the message (a plain-text and an HTML version).
#text = "Hi!\nHow are recipient?\nHere is the link recipient wanted:\nhttp://www.python.org"
#html = "This is the <b>HTML</b> body."

# Record the MIME types of both parts - text/plain and text/html.
#part1 = MIMEText(text, 'plain')
part2 = MIMEText(html, 'html')

# Attach parts into message container.
# According to RFC 2046, the last part of a multipart message, in this case
# the HTML message, is best and preferred.
#msg.attach(part1)
msg.attach(part2)

# Send the message.
mailServer = smtplib.SMTP('smtp.gmail.com', 587)
mailServer.ehlo()
mailServer.starttls()
mailServer.ehlo()
mailServer.login(gmailUser, gmailPassword)
mailServer.sendmail(gmailUser, recipient, msg.as_string())
mailServer.quit() #KH THIS WAS .close()
print('Sent email to %s' % recipient)
