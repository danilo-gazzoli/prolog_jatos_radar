class Controls{
    constructor(type, timeForUpdateProlog=100){
        this.forward=false;
        this.left=false;
        this.right=false;
        this.reverse=false;
        this.boom=false;
        this.timeForUpdateProlog=timeForUpdateProlog;
        this.lastUpdate=Date.now();
        this.requestPending=false;

        switch(type){
            case "KEYS":
                this.#addKeyboardListeners();
                break;
            case "DUMMY":
                this.forward=Math.random() > 0.5;
                this.reverse=!this.forward;
                this.left=Math.random() > 0.5;
                this.right=!this.left;
                break;
            case "PROLOG":
                // this.updateProlog();
                break;
        }
    }

    updateJSONKeys(controls) {
        //console.log(controls);
        this.forward = (controls.forward)?true:false;
        this.reverse = (controls.reverse)?true:false;
        this.left = (controls.left)?true:false;
        this.right = (controls.right)?true:false;
        this.boom = (controls.boom)?true:false;
        //console.log('forward: '+this.forward+' ('+controls.forward+') -- reverse: '+this.reverse+' ('+controls.reverse+') -- '+
        //            'left: '+this.left+' ('+controls.left+') -- right: '+this.right+' ('+controls.right+')'+this.boom+' ('+controls.boom+')');
        //console.log('MSG: '+this.msg);
    }

    updateProlog(x, y, angle, prologID, score, speed, jets = [], booms = [], self=null) {
        if (this.requestPending) return;
        if (Date.now() - this.lastUpdate < this.timeForUpdateProlog) return;
        if (x==undefined || y==undefined || angle==undefined || speed==undefined) return;

        this.lastUpdate = Date.now();
        this.requestPending=true;

        // Lista de adversários.
        const adversarios = [];
        for (let i = 0; i < jets.length; i++) {
            const jet=jets[i];
            if (jet==undefined || jet===self || jet.score <=0) continue;

            const ax = Number(jets[i].x), ay = Number(jets[i].y);
            if (!Number.isFinite(ax) || !Number.isFinite(ay)) continue;

            adversarios.push([ax,ay]);
        }

        // Lista de mísseis.
        const misseis = [];
        for (let i = 0; i < booms.length; i++) {
            const boom=booms[i];
            if (booms==undefined || booms.deactivated) continue;

            const bx = Number(booms[i].x), by = Number(booms[i].y);
            if (!Number.isFinite(bx) ||!Number.isFinite(by)) continue;

            misseis.push([bx,by]);
        }

        const URL="./action?"+
                  "id="+encodeURIComponent(prologID)+
                  "&x="+encodeURIComponent(x)+
                  "&y="+encodeURIComponent(y)+
                  "&angle="+encodeURIComponent(angle)+
                  "&score="+encodeURIComponent(score)+
                  "&speed="+encodeURIComponent(speed)+
                  "&adversarios="+encodeURIComponent(JSON.stringify(adversarios))+
                  "&misseis="+encodeURIComponent(JSON.stringify(misseis));
        // DEBUG:
        //console.log(URL);
        fetch(URL,{cache:"no-store"})
            .then(response=>{
                if (!response.ok) throw new Error("HTTP "+response.status);
                return response.json();
            })
            .then(controls=>this.updateJSONKeys(controls))
            .catch(error=>console.error("Erro ao consultar Prolog:",error))
            .finally(()=>{this.requestPending=false;});
    }

    updateDUMMYKeys() {
        if (Date.now() - this.lastUpdate < 1000) {
            return;
        }
        this.lastUpdate = Date.now();
        const r = Math.random();
        if (r < 0.4) {
            this.forward = true;
            this.reverse = false;
            this.left = false;
            this.right = false;
        } else if (r < 0.5) {
            this.reverse = true;
            this.forward = false;
            this.left = false;
            this.right = false;
        } else if (r < 0.8) {
            this.forward = true;
            this.reverse = false;
            this.left = true;
            this.right = false;
        } else {
            this.forward = true;
            this.reverse = false;
            this.left = false;
            this.right = true;
        }
        this.boom = r < 0.3;
    }

    getBOOM() {
        let ret = this.boom;
        this.boom = false;
        return ret;
    }

    #addKeyboardListeners(){
        document.addEventListener("keydown",(event)=>{
            switch(event.key){
                case "ArrowLeft": this.left=true; break;
                case "ArrowRight": this.right=true; break;
                case "ArrowUp": this.forward=true; break;
                case "ArrowDown": this.reverse=true; break;
                case "Enter":
                case " ": this.boom=true; break;
            }
        });
        document.addEventListener("keyup",(event)=>{
            switch(event.key){
                case "ArrowLeft": this.left=false; break;
                case "ArrowRight": this.right=false; break;
                case "ArrowUp": this.forward=false; break;
                case "ArrowDown": this.reverse=false; break;
            }
        });
    }
}
