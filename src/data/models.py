# ruff: noqa: D101
"""Sqlalchemy models for data collection process."""

from sqlalchemy import BigInteger
from sqlalchemy import Boolean
from sqlalchemy import Column
from sqlalchemy import Date
from sqlalchemy import DateTime
from sqlalchemy import ForeignKey
from sqlalchemy import Integer
from sqlalchemy import String
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import relationship

Base = declarative_base()

class Channel(Base):
    __tablename__ = "channels"

    id = Column(String, primary_key=True)
    title = Column(String)
    description = Column(String)
    channel_follower_count = Column(BigInteger)

    videos = relationship("Video", uselist=True, back_populates="channel")


class Video(Base):
    __tablename__ = "videos"

    id = Column(String, primary_key=True)
    title = Column(String)
    description = Column(String)
    channel_id = Column(String, ForeignKey("channels.id"), index=True)
    datetime_upload = Column(Date)
    duration = Column(Integer)
    view_count = Column(BigInteger)
    like_count = Column(BigInteger)
    comment_count = Column(BigInteger)
    was_live = Column(Boolean)
    relative_file_path = Column(String)

    comments = relationship("Comment", uselist=True, back_populates="video")
    channel = relationship("Channel", uselist=False, back_populates="videos")


class Comment(Base):
    __tablename__ = "comments"

    id = Column(String, primary_key=True)
    video_id = Column(String, ForeignKey("videos.id"), nullable=False)
    text = Column(String)
    datetime_upload = Column(DateTime)
    parent = Column(String)
    like_count = Column(Integer)
    author = Column(String)
    author_is_uploader = Column(Boolean)
    is_favorited = Column(Boolean)

    video = relationship("Video", uselist=False, back_populates="comments")
