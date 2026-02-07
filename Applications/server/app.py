from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
import models
import db_models
from database import engine, get_db

# Create tables
db_models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Linux Telemetry Server")

@app.post("/api/v1/telemetry", status_code=status.HTTP_201_CREATED)
def ingest_telemetry(payload: models.TelemetryPayload, db: Session = Depends(get_db)):
    # 1. Register/Update Agent
    agent = db.query(db_models.Agent).filter(db_models.Agent.id == payload.agent_id).first()
    if not agent:
        agent = db_models.Agent(id=payload.agent_id)
        db.add(agent)
    
    agent.last_seen = datetime.utcnow()
    
    # 2. Store Telemetry
    record = db_models.TelemetryRecord(
        agent_id=payload.agent_id,
        timestamp=payload.timestamp,
        sys_info=payload.system.dict(),
        cpu_info=payload.cpu.dict(),
        memory_info=payload.memory.dict(),
        disk_info=[d.dict() for d in payload.disks],
        process_info=[p.dict() for p in payload.processes],
        network_interfaces=[n.dict() for n in payload.network_interfaces],
        users=[u.dict() for u in payload.users],
        security_info=payload.security.dict()
    )
    
    db.add(record)
    db.commit()
    
    return {"status": "received", "agent_id": payload.agent_id}

@app.get("/api/v1/agents")
def list_agents(db: Session = Depends(get_db)):
    agents = db.query(db_models.Agent).all()
    return agents

@app.get("/api/v1/reports/{agent_id}")
def get_latest_report(agent_id: str, db: Session = Depends(get_db)):
    record = db.query(db_models.TelemetryRecord)\
        .filter(db_models.TelemetryRecord.agent_id == agent_id)\
        .order_by(db_models.TelemetryRecord.timestamp.desc())\
        .first()
    
    if not record:
        raise HTTPException(status_code=404, detail="No data found for this agent")
        
    return record
