from sqlalchemy import Column, Integer, String, Float, ForeignKey, JSON, DateTime
from sqlalchemy.orm import relationship
from database import Base
import datetime

class Agent(Base):
    __tablename__ = "agents"

    id = Column(String, primary_key=True, index=True)
    last_seen = Column(DateTime, default=datetime.datetime.utcnow)
    
    telemetry_records = relationship("TelemetryRecord", back_populates="agent")

class TelemetryRecord(Base):
    __tablename__ = "telemetry_records"

    id = Column(Integer, primary_key=True, index=True)
    agent_id = Column(String, ForeignKey("agents.id"))
    timestamp = Column(Float)
    received_at = Column(DateTime, default=datetime.datetime.utcnow)
    
    # Storing the structured data as JSON for flexibility in this prototype
    # In a full production system, we might normalize this into separate tables
    sys_info = Column(JSON)
    cpu_info = Column(JSON)
    memory_info = Column(JSON)
    disk_info = Column(JSON)
    process_info = Column(JSON)
    network_interfaces = Column(JSON)
    users = Column(JSON)
    security_info = Column(JSON)

    agent = relationship("Agent", back_populates="telemetry_records")
