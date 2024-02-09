# ruff: noqa: D101
"""Sqlalchemy models for data collection process."""

from sqlalchemy import BigInteger
from sqlalchemy import Boolean
from sqlalchemy import Column
from sqlalchemy import Date
from sqlalchemy import DateTime
from sqlalchemy import Float
from sqlalchemy import ForeignKey
from sqlalchemy import Integer
from sqlalchemy import String
from sqlalchemy.orm import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.types import ARRAY

Base = declarative_base()


class Channel(Base):
    __tablename__ = "channels"

    id = Column(String, primary_key=True)
    channel = Column(String, index=True)
    uploader_id = Column(String, index=True)
    title = Column(String)
    description = Column(String)
    channel_follower_count = Column(BigInteger)
    channel_url = Column(String)
    playlist_count = Column(Integer)

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
    format = Column(String, index=True)
    is_valid = Column(Boolean, server_default="true", index=True)

    comments = relationship("Comment", uselist=True, back_populates="video")
    channel = relationship("Channel", uselist=False, back_populates="videos")
    transcript = relationship("Transcript", uselist=False, back_populates="video")
    sentences = relationship("Sentence", uselist=True, back_populates="video")


class Comment(Base):
    __tablename__ = "comments"
    __table_args__ = {"extend_existing": True}

    id = Column(String, primary_key=True)
    video_id = Column(String, ForeignKey("videos.id"), nullable=False, index=True)
    text = Column(String)
    datetime_upload = Column(DateTime)
    parent = Column(String)
    like_count = Column(Integer)
    author = Column(String)
    author_is_uploader = Column(Boolean)
    is_favorited = Column(Boolean)
    is_valid = Column(Boolean, server_default="true", index=True)

    video = relationship("Video", uselist=False, back_populates="comments")


class Transcript(Base):
    __tablename__ = "transcripts"

    id = Column(String, ForeignKey("videos.id"), primary_key=True)
    model_type = Column(String)
    text = Column(String)

    video = relationship("Video", uselist=False, back_populates="transcript")


class Sentence(Base):
    __tablename__ = "sentences"

    id = Column(Integer, primary_key=True)
    video_id = Column(String, ForeignKey("videos.id"), ForeignKey("transcripts.id"), index=True)
    sentence_no = Column(Integer, index=True)
    elite = Column(Boolean)
    pplcentr = Column(Boolean)
    left = Column(Boolean)
    right = Column(Boolean)
    manifesto_class = Column(String, index=True)
    manifesto_confidence = Column(Float, index=True)
    tokens = Column(ARRAY(String))
    is_valid = Column(Boolean, server_default="true", index=True)

    video = relationship("Video", uselist=False, back_populates="sentences")
