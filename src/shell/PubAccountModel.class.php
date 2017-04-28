<?php
class PubAccountModel extends Model{
	
	public function getCmdParameters(){
		$cmdParam = "";
		if(!empty($this->pbxid)){
			$cmdParam .= " -i ".$this->pbxid;
		}
		$cmdParam .= sprintf(" -u '%s'",$this->uri);
		$cmdParam .= sprintf(" -e '%s'",$this->registrar);
		$cmdParam .= sprintf(" -r '%s'",$this->realm);
		$cmdParam .= sprintf(" -n '%s'",$this->auth_username);
		$cmdParam .= sprintf(" -p '%s'",$this->password);
		$cmdParam .= sprintf(" -o '%s'",$this->proxy);
		$cmdParam .= sprintf(" -c '%s'",$this->max_in_call);
		$cmdParam .= sprintf(" -a '%s'",$this->max_out_call);
		$cmdParam .= sprintf(" -l '%s'",$this->max_in_out_call);
		$cmdParam .= sprintf(" -f '%s'",$this->out_call_prefix);
		$cmdParam .= sprintf(" -d '%s'",$this->area_code);
		$cmdParam .= sprintf(" -t '%s'",$this->type);
		$cmdParam .= sprintf(" -m %s",$this->gw_mode);
		$cmdParam .= sprintf(" -s %s",$this->outside_type);
		$cmdParam .= sprintf(" -y %s",$this->outside_callnumber);
		
		if(strlen($this->status) > 0) $cmdParam .= sprintf(" -j %s",$this->status);
		if(strlen($this->pstn_teleconf_type)>0) $cmdParam .= sprintf(" -w %s",$this->pstn_teleconf_type);
		if(strlen($this->pstn_teleconf_max)>0) $cmdParam .= sprintf(" -v %s",$this->pstn_teleconf_max);
		return $cmdParam;
	}
	
	public function getCmdParametersFromDatas($paDatas){
		$cmdParam = "";
		if(!empty($paDatas['pbxid'])){
			$cmdParam .= " -i ".$paDatas['pbxid'];
		}
		if(!empty($paDatas['uri'])) $cmdParam .= sprintf(" -u '%s'",$paDatas['uri']);
		if(!empty($paDatas['registrar'])) $cmdParam .= sprintf(" -e '%s'",$paDatas['registrar']);
		if(!empty($paDatas['realm'])) $cmdParam .= sprintf(" -r '%s'",$paDatas['realm']);
		if(!empty($paDatas['auth_username'])) $cmdParam .= sprintf(" -n '%s'",$paDatas['auth_username']);
		if(!empty($paDatas['password'])) $cmdParam .= sprintf(" -p '%s'",$paDatas['password']);
		if(!empty($paDatas['proxy'])) $cmdParam .= sprintf(" -o '%s'",$paDatas['proxy']);
		if(!empty($paDatas['max_in_call'])) $cmdParam .= sprintf(" -c '%s'",$paDatas['max_in_call']);
		if(!empty($paDatas['max_out_call'])) $cmdParam .= sprintf(" -a '%s'",$paDatas['max_out_call']);
		if(!empty($paDatas['max_in_out_call'])) $cmdParam .= sprintf(" -l '%s'",$paDatas['max_in_out_call']);
		if(!empty($paDatas['out_call_prefix'])) $cmdParam .= sprintf(" -f '%s'",$paDatas['out_call_prefix']);
		if(!empty($paDatas['area_code'])) $cmdParam .= sprintf(" -d '%s'",$paDatas['area_code']);
		if(!empty($paDatas['type'])) $cmdParam .= sprintf(" -t '%s'",$paDatas['type']);
		if(!empty($paDatas['gw_mode'])) $cmdParam .= sprintf(" -m %s",$paDatas['gw_mode']);
		if(!empty($paDatas['outside_type'])) $cmdParam .= sprintf(" -s %s",$paDatas['outside_type']);
		if(!empty($paDatas['outside_callnumber'])) $cmdParam .= sprintf(" -y %s",$paDatas['outside_callnumber']);
		
		if(strlen($paDatas['status']) > 0)	$cmdParam .= sprintf(" -j %s",$paDatas['status']);
		
		if(strlen($paDatas['pstn_teleconf_type'])>0) $cmdParam .= sprintf(" -w %s",$paDatas['pstn_teleconf_type']);
		if(strlen($paDatas['pstn_teleconf_max'])>0) $cmdParam .= sprintf(" -v %s",$paDatas['pstn_teleconf_max']);
		return $cmdParam;
	}
	
	public static function DeleteEpAllPubAccount($eid){
		$pubAccount = new PubAccountModel();
		$map["eid"] = $eid;
		$pbxIds = $pubAccount->field("id,pbxid")->where($map)->select();
		setEnterpriseEnvironment($eid);
		foreach ($pbxIds as $pbxId){
			if($pbxId['pbxid'] > 0){
				$voipCmd = new VoipCmd();
				$voipCmd->deletePubAccount($pbxId['pbxid']);
                                //SyncModel::LineDelete($pbxId['id'],$eid);
			}			
		}
		$pubAccount->where($map)->delete();
	}
	
	public static function DeletePubAccount($paid){
		$pubAccount = new PubAccountModel();
		$pas = $pubAccount->find($paid);
		if($pas != null){
			$paids = array();
			$paids[] = $pas['id'];
			//删除关联表
			self::UnbindMemberOutnumber($pas['eid'], null, $paids);
			//删除部门外线
			self::removeDeptOutnumberByPaid($pas['id']);
			//删除公共账户
			if(!empty($pas['pbxid'])){
				setEnterpriseEnvironment($pas['eid']);
				$voipCmd = new VoipCmd();
				$voipCmd->deletePubAccount($pas['pbxid']);
				//直线号码删除关联关系
				$smModel = new SipMemberModel();
				$smMap['eid'] = $pas['eid'];
				$smMap['paid'] = $pas['pbxid'];
			    $smModel->where($smMap)->find();
				if($smModel->id > 0){
					$smModel->paid = "";
					$smModel->outside_callnumber = "";
					SipMemberModel::saveAndLog($smModel,false);
				}
			}
			$pubAccount->delete($paid);
                        //SyncModel::LineDelete($paid,$pas['eid']);
		}
	}
	
	public static function ReleasePubAccount($paid){
		$pubAccount = new PubAccountModel();
		$pas = $pubAccount->find($paid);
		if($pas != null){
			//删除关联表
			$mo = M("MemberOutnumber");
			$moMap['paid'] = $paid;
			$mo->where($moMap)->delete();
			//删除公共账户
			if(!empty($pas['pbxid']) && !empty($pas['eid'])){
				setEnterpriseEnvironment($pas['eid']);
				$voipCmd = new VoipCmd();
				$voipCmd->deletePubAccount($pas['pbxid']);
                                SyncModel::LineUpdate($paid,$pas['eid']);
			}
			//清空sipmember相关记录
			$sm = new SipMemberModel();
			$smMap['paid'] = $pas['pbxid'];
			$smMap['eid'] = $pas['eid'];
			$uid = $sm->where($smMap)->getField("uid");
			if($uid > 0){
				$smData['paid'] = -1;
				$smData['outside_callnumber'] = "";
				$sm->where($smMap)->save($smData);
				//记录sync信息
				SyncModel::UserUpdate($uid);
			}
			$pubAccount->eid=0;
			$pubAccount->epname="";
			$pubAccount->pbxid=0;
			$pubAccount->uri = $pubAccount->registrar = $pubAccount->auth_username = $pubAccount->username = $pubAccount->password = $pubAccount->proxy = $pubAccount->port = "";
			$pubAccount->save(); 
		}
	}
	
	public static function GetPbxId($eid){
		setEnterpriseEnvironment($eid);
		$voipCmd = new VoipCmd();
		$retArr = array();
		$paDatas = $voipCmd->getPubAccounts();
		foreach($paDatas as $paData){
			$data = explode("|",$paData);
			$retArr[$data[1]] = $data[0];
		}
		return $retArr;
	}
	
	public static function GetPbxPubAccount($eid){
		setEnterpriseEnvironment($eid);
		$voipCmd = new VoipCmd();
		$retArr = array();
		$paDatas = $voipCmd->getPubAccounts();
		foreach($paDatas as $paData){
			$retArr[] = self::ParsePubAccount($paData);
		}	
		return $retArr;
	}
	
	public static function ParsePubAccount($pubAccount){
		$retArr = array();
		$data = explode("|",$pubAccount);
		$retArr["pbxid"] = $data[0];
		$retArr["uri"] = $data[1];
		$parsers = preg_split("/[:@]{1}/",$data[1],3);
		$retArr["username"] = $parsers[1];
		$retArr["devicedomain"] = $parsers[2];
		$retArr["registrar"] = $data[2];
		$retArr["realm"] = $data[3];
		$retArr["auth_username"] = $data[4];
		$retArr["password"] = $data[5];
		$retArr["proxy"] = $data[6];
		$retArr["max_in_call"] = $data[7];
		$retArr["max_out_call"] = $data[8];
		$retArr["max_in_out_call"] = $data[9];
		$retArr["out_call_prefix"] = $data[10];
		$retArr["area_code"] = $data[11];
		$retArr["type"] = $data[12];
		$retArr["gw_mode"] = $data[13];
		$retArr["outside_type"] = $data[14];
		$retArr["outside_callnumber"] = $data[15];
		return $retArr;
	}
	
	public static function GetOutsideCallnumbers($eid){
		$pubAccount = new PubAccountModel();
		$map["eid"] = $eid;
		//$map['outside_type'] = 0;
		return $pubAccount->field("id,uri,pbxid,area_code,outside_callnumber")->where($map)->select();
	}
    //获取 type=1 直线号码
	public static function GetOutsideCallnumbersByType($eid,$type='1'){
		$pubAccount = new PubAccountModel();
		$map["eid"] = $eid;
		$map["outnumber_type"] = $type;
		//$map['outside_type'] = 0;
		return $pubAccount->field("id,uri,pbxid,area_code,outside_callnumber")->where($map)->select();
	}
	
	public static function GetOutsideCallnumber($eid,$pbxid){
		$pubAccount = new PubAccountModel();
		$map["eid"] = $eid;
		$map['pbxid'] = $pbxid;
		$outsideNumber = $pubAccount->field("id,area_code,outside_callnumber")->where($map)->select();
		//echo $pubAccount->getLastSql();
		if($outsideNumber != null){
			return $outsideNumber[0]["area_code"]."-".$outsideNumber[0]['outside_callnumber'];
		}
		return null;
	}
	
	public static function GetPubaccounts($did,$searchStr){
		$pam = new PubAccountModel();
		$map['did'] = $did;
	   
		if(!empty($searchStr)){
			$where['province_city'] = array('like',"%".$searchStr."%");
			$where['outside_callnumber'] = array('like',"%".$searchStr."%");
			$where['area_code'] = array('like',"%".$searchStr."%");
			$where['epname'] = array('like',"%".$searchStr."%");
			$where['_logic'] = 'or';
			$map['_complex'] = $where;
			
			$whereSql = sprintf(" and (pa.province_city like '%%%1\$s%%' or pa.outside_callnumber like '%%%1\$s%%' or pa.area_code like '%%%1\$s%%' or ep.name  like '%%%1\$s%%')",$searchStr);
		}
			
		$count = $pam->where($map)->count();
		import("@.ORG.Util.Page");
		$p = new Page($count);
		$p->showPerPageRows = true;
		if(!empty($searchStr)){
			$p->parameter .= "&searchStr=".urlencode($searchStr);
		}
		$p->parameter .= "&did=".$did;
		$model = new Model();
		$field = "pa.id,pa.outside_callnumber,pa.area_code,pa.province_city,pa.eid,ep.name as epname,pa.outside_type,pa.pbxid,pa.outnumber_type";
		$sql = sprintf("select %s from talk_pub_account pa left join talk_enterprise  ep on pa.eid=ep.id where pa.did=%d %s limit %d,%d",$field,$did,$whereSql,$p->firstRow,$p->listRows);
		$result = $model->query($sql);
		//$p->resultList = $pam->field($field)->where($map)->limit($p->firstRow . ',' . $p->listRows)->select();
		$p->resultList = $result;
		//echo $pam->getLastSql();
		return $p;
	}
	
	public static function GetMainCallNumber($eid){
		$pam = new PubAccountModel();
		$map['eid'] = $eid;
		$map['outnumber_type'] = array(array('eq',0),array('eq',2),'or'); 
		$map['area_code'] = array("neq","9999");
		$field = "id,outside_callnumber,area_code,province_city,outnumber_type,pstn_teleconf_type";
		$result = $pam->where($map)->field($field)->select();
		//echo $pam->getLastSql();
		return $result;
	}
	
	public static function GetUsedMainCallNumber($eid){
		$mom = M("MemberOutnumber");
		$map['eid'] = $eid;
		$result = $mom->where($map)->select();
		$paids = array();
		foreach ($result as $row){
			$paid = $row['paid'];
			if(!in_array($paid, $paids)){
				$paids[] = $paid;
			}
		}
		return $paids;
	}
	/**
	 * 判断号码是否是已使用的总机号码
	 * @param unknown_type $paid
	 * @param unknown_type $eid
	 * @return boolean true(used) false(not used)
	 */
	public static function IsUsedSwitchNumber($paPbxid,$eid){
		$mom = M("MemberOutnumber");
		if(!empty($eid)) $map['eid'] = $eid;
		$map['paid'] = $paPbxid;
		$result = $mom->where($map)->find();
		//echo $mom->getLastSql();
		return !empty($result);
	}
	
	public static function IsUsedDirectNumber($paid,$eid=null){
		$em = new SipMemberModel();
		if(!empty($eid)) $map['eid'] = $eid;
		$map['paid'] = $paid;
		$em->where($map)->find();
		//echo $em->getLastSql();
		return ($em->id>0);
	}
	
	public static function GetSecondCallNumber($eid){
		$pam = new PubAccountModel();
		//$secondNumber = SipMemberModel::GetPaids($eid);
		$mids = self::GetUsedMainCallNumber($eid);
		$map['eid'] = $eid;
		if(!empty($mids)){
			$map['id'] = array('not in',$mids);
		}
		$field = "id,outside_callnumber,area_code,province_city,pbxid";
		$result = $pam->where($map)->field($field)->select();
		//echo $pam->getLastSql();
		return $result;
	}
	
	public static function GetDirectNumbers($eid){
		$paModel = new PubAccountModel();
		$map['eid'] = $eid;
		$map['outnumber_type'] = 1;
		$map['area_code'] = array("neq","9999");
		$field = "id,outside_callnumber,area_code,province_city,pbxid";
		$result = $paModel->where($map)->field($field)->select();
		//echo $pam->getLastSql();
		return $result;
	}
	
	/**
	 * 获取未使用直拨号码，如果用户已有直线号码，则该号码也返回
	 * @param unknown_type $eid
	 * @param unknown_type $mid
	 * @return unknown
	 */
	public static function GetUnUserDirectNumbers($eid,$mid=null){
		$smModel = new SipMemberModel();
		$smMap['eid'] = $eid;
		$smMap['paid'] = array("gt",0);
		if(!empty($mid)) $smMap['id'] = array("NEQ",$mid);
		$pbxIdArr = $smModel->where($smMap)->getField("id,paid");
		//echo $smModel->getLastSql();
		$usedPbxIds = array_values($pbxIdArr);
		
		$paModel = new PubAccountModel();
		$map['eid'] = $eid;
		$map['outnumber_type'] = 1;
		$map['area_code'] = array("neq","9999");
		if(!empty($usedPbxIds)) $map['pbxid'] = array("not in",$usedPbxIds);
		$field = "id,outside_callnumber,area_code,province_city,pbxid";
		$order = "area_code,outside_callnumber asc";
		$result = $paModel->where($map)->field($field)->order($order)->select();
		//echo $paModel->getLastSql();
		return $result;
	}
	/**
	 * 获取未绑定总机，即企业总机。
	 * @param int $eid 企业id
	 * @return array 总机数组
	 */
	public static function GetUnBindSwitchNumber($eid){
		$m = new Model();
		$sql = sprintf("select id,outside_callnumber,area_code,pbxid,province_city,outnumber_type,pstn_teleconf_type from talk_pub_account 
				where outnumber_type=0 and eid='%1\$s' and id not in (select distinct paid from talk_member_outnumber where eid='%1\$s')",$eid);
		ExLog::log("get un bind switch number:".$sql,log::DEBUG);
		return $m->query($sql);
	}
	
	public static function GetSwitchNumbers($eid){
		$paModel = new PubAccountModel();
		$paMap['outnumber_type'] = 0;
		$paMap['eid'] = $eid;
		$field = "id,outside_callnumber,area_code,pbxid,province_city,outnumber_type,pstn_teleconf_type";
		$paDatas = $paModel->field($field)->where($paMap)->select();
		ExLog::log("get switch number:".$paModel->getLastSql(),log::DEBUG);
		return $paDatas;
	}
	/**
	 * 获取用户绑定总机
	 * @param int $eid 企业id
	 * @param int $mid 用户id
	 * @return array 总机数组
	 */
	public static function GetMemberBindSwitchNumber($eid,$mid){
		$m = new Model();
		$sql = sprintf("select distinct b.id,b.outside_callnumber,b.area_code,b.pbxid,b.province_city,b.outnumber_type,b.pstn_teleconf_type 
				from talk_member_outnumber a,talk_pub_account b where a.eid=b.eid and b.outnumber_type=0 and a.paid=b.id and a.eid='%s' and a.mid='%s'",$eid,$mid);
		return $m->query($sql);
	}
	/**
	 * 递归获取部门总机。
	 * @param int $eid 企业id
	 * @param int $gid 分组id
	 * @return array 总机数组
	 */
	public static function GetGroupSwitchNumber($eid,$gid){
		$paDatas = array();
		if($gid > 0){
			$gids = EnterpriseGroupModel::GetParentIds($eid, $gid);
			$gids[] = $gid;
			$paids = PubAccountModel::GetDeptOutnumber($gids);
			
			if(!empty($paids)){
				$paModel = new PubAccountModel();
				$paMap['id'] = array("in",$paids);
				$field = "id,outside_callnumber,area_code,pbxid,province_city,outnumber_type,pstn_teleconf_type";
				$paDatas = $paModel->field($field)->where($paMap)->select();
			}
		}
		return $paDatas;
	}
	
	public static function GetOutnumbers($eid,$mid){
		$m = new Model();
		$sql = sprintf("select distinct b.id,b.outside_callnumber,b.area_code,b.pbxid,b.province_city,b.outnumber_type,b.pstn_teleconf_type from talk_member_outnumber a,talk_pub_account b where a.eid=b.eid and a.paid=b.id and a.eid='%s' and a.mid='%s'",$eid,$mid);
		//log::write($sql);
		return $m->query($sql);
	}
	
	public static function CountSwitchNumber($eid){
		$pam = new PubAccountModel();
		$map['eid'] = $eid;
		$map['outnumber_type'] = 0;
		/* $secondNumber = SipMemberModel::GetPaids($eid);
		 if(!empty($secondNumber)){
		$map['id'] = array('not in',$secondNumber);
		} */
		$result = $pam->where($map)->count();
		//echo $pam->getLastSql();
		return $result;
	}
	
	public static function GetEpFirstSwitchNumber($eid){
		$paModel = new PubAccountModel();
		$map['eid'] = $eid;
		$map['outnumber_type'] = 0;
		$map['area_code'] = array("neq","9999");
		$map['pbxid'] = array("gt","0");
		//$map['_string'] = sprintf("id not in (select paid from talk_member_outnumber where eid='%s')",$eid);
		$field = "id,outside_callnumber,area_code,province_city,pbxid,call_permission";
		$paFirstSwitch = $paModel->field($field)->where($map)->find();
		log::write($paModel->getLastSql());
		return $paFirstSwitch;
	}
	
	public static function IsNumberExist($numbers){
		$paModel = new PubAccountModel();
		$map['area_code'] = $numbers[0];
		$map['outside_callnumber'] = $numbers[1];
		return $paModel->where($map)->find();
	}
	
	public static function GetPubAccountFromEid($eid,$numbers){
		$paModel = new PubAccountModel();
		$map['eid'] = $eid;
		$map['area_code'] = $numbers[0];
		$map['outside_callnumber'] = $numbers[1];
		return $paModel->where($map)->find();
	}
	
	public static function GetEpNumberCount($eid){
		$paModel = new PubAccountModel();
		$map['eid'] = $eid;
		return $paModel->where($map)->count();
	}
	
	/**
	 * 根据pbxid获取外线号码
	 * @param unknown_type $eid
	 * @param unknown_type $pbxId
	 * return paData
	 */
	public static function GetNumberByPbxId($eid,$pbxId){
		$paModel = new PubAccountModel();
		$map['eid'] = $eid;
		$map['pbxid'] = $pbxId;
		$paData = $paModel->where($map)->find();
		return $paData;
	}
	
	public static function GetSwitchNumber($eid,$number){
		$numbers = MobileLocation::GetAreaCode($number);
		if(count($numbers) < 2) return false;
		$paModel = new PubAccountModel();
		$map['eid'] = $eid;
		$map['area_code'] = $numbers[0];
		$map['outside_callnumber'] = $numbers[1];
		//$map['outside_type'] = 0;
		$map['outnumber_type'] = 0;
		$result = $paModel->where($map)->find();
		//log::write("GetSwitch:".$paModel->getLastSql());
		return $result;
	}
	
	public static function FindSwitchNumber($number){
		$numbers = MobileLocation::GetAreaCode($number);
		if(count($numbers) < 2) return false;
		$paModel = new PubAccountModel();
		$map['area_code'] = $numbers[0];
		$map['outside_callnumber'] = $numbers[1];
		//$map['outside_type'] = 0;
		$map['outnumber_type'] = 0;
		$result = $paModel->where($map)->find();
		//log::write("GetSwitch:".$paModel->getLastSql());
		return $result;
	}
	
	private static $INBIND_AREA = array("0571","0516","0527","0318","0310","0335"
			,"0319","0315","0314","0317","0312","0313","0316","021","0553","0555"
			,"0562","0556","0552","0563","0554","0561","0564","0566","0559","0731"
			,"0734","0739","0730","0736","0744","0737","0735","0746","0745","0738"
			,"0743"
	);
	/**
	 * 添加外线号码
	 * @param array $epDatas 企业数据
	 * @param array $paDatas 需添加的外线号码数组
	 * @return array 外线号码数组，失败返回null
	 */
	public static function AddPubAccountFromBss($epDatas,$paDatas){
		$eid = $epDatas['id'];
		$number = $paDatas['area_code'].$paDatas['outside_callnumber'];
		if(empty($paDatas['physical_number'])) $paDatas['physical_number'] = $number;
		log::write("add line:".$number." in eid:".$eid);
		if(empty($eid) || empty($number)) return null;
		$province = ParamModel::GetServerProvince();
		//start
		if($paDatas['pms_domain']){
		    $device = DeviceModel::CheckAndGetDevice($paDatas['pms_domain'], $paDatas['pms_dport'], $paDatas['pms_dtype']);
		    $port = $paDatas['pms_dport'];
		}else{
		    //获取ngn设备
		    $device = DeviceModel::GetNGN();
		    //获取ngn端口
		    $port = DeviceModel::GetNGNPort();
		}
		$uTime = time();
		$paModel = new PubAccountModel();
		$paDatas['eid'] = $eid;
		$paDatas['did'] = $device['id'];
		$paDatas['line_name']  = "ngn_".$number;
		$paDatas['port'] = $port;
		$paDatas['devicename'] = $device['device_name'];
		$paDatas['epname'] = $epDatas['name'];
		$paDatas['device_type'] = $device['device_type'];
		switch($province){
			case "zhejiang":
				$paDatas['username'] = "1116445".$paDatas['outside_callnumber'];
				break;
			case "hebei":
			case "henan":
			case "shanghai":
				$paDatas['username'] =  "1".$paDatas['outside_callnumber'];
				break;
			default:
				$paDatas['username'] =  "1".$paDatas['physical_number'];
				break;
		}
		//判断是否使用注册模式
		$paDatas['auth_username'] = (!empty($paDatas['PaLoginName']))?$paDatas['PaLoginName']:$paDatas['username'];
		$paDatas['password'] = (!empty($paDatas['PaPassword']))?$paDatas['PaPassword']:"123456";
		$paDatas['uri'] = DeviceModel::GetUri($paDatas['username'], $device["device_domain"]);
		$paDatas['registrar'] = $paDatas['proxy'] = DeviceModel::GetRegistar($device["device_domain"], $port);
		$paDatas['realm'] = "*";		
		$paDatas['change_flag'] = 0;
		if(in_array($paDatas['area_code'],self::$INBIND_AREA) === true){
			$paDatas['dtmf_type'] = 1;
		}else{
			$paDatas['dtmf_type'] = 0;
		}	
		$paDatas['type'] = self::GetPubAccountType($paDatas['device_type'],$paDatas['change_flag'],$paDatas['dtmf_type']);
		//使用外线管理服务器需
		$paDatas['out_call_prefix'] = "9";
		
		switch($province){
			case "shanghai":
			case "shaanxi":
				$paDatas['gw_mode'] = 2;//设置为sip trunk
				break;
			default:
				$paDatas['gw_mode'] = 1;//设置为regs mode
				break;
		}
		setEnterpriseEnvironment($eid);
		$voipCmd = new VoipCmd();
		log::write("add line in pbx");
		//支持异地外线设置
		if(isset($paDatas['otherFlag']) && $paDatas['otherFlag'] == 1) $paDatas['outside_type'] = 3;
		$result = $voipCmd->insertPubAccount($paModel->getCmdParametersFromDatas($paDatas));
		if($result > 0){
			log::write("insert pubaccount fail：".$number);
			return null;
		}
		//获取pbxid
		//$paIds = PubAccountModel::GetPbxId($eid);
		$paDatas['pbxid'] = SipAccountPubModel::GetPbxId($eid, $paDatas['area_code'], $paDatas['outside_callnumber']);
		log::write("find line in pbx:".$paDatas['pbxid']);
			
		$paDatas['id'] = $paModel->add($paDatas);
                SyncModel::LineAdd($paDatas['id'],$eid);
		log::write("addlinesql:".$paModel->getLastSql());
		return $paDatas;
	}
	
	public static function AddSwitchNumber($ep,$numbers,$plancode,$callpermission,$limitLine,$extPlancode){
		return self::AddNumber($ep, $numbers, $plancode, $callpermission, 0, $limitLine,$extPlancode);
	}
	
	public static function AddDirectNumber($ep,$numbers,$plancode,$callpermission,$limitLine,$extPlancode){
		return self::AddNumber($ep, $numbers, $plancode, $callpermission, 1, $limitLine,$extPlancode);
	}
	
	public static function AddNumber($ep,$numbers,$plancode,$callpermission,$outType,$limitLine,$extPlancode){
		log::write("add line:".$outType);
		$eid = $ep['id'];
		if(empty($numbers) || empty($eid)) return false;
		
		$number = $numbers[0].$numbers[1];
		$device = DeviceModel::GetNGN();
		$uTime = time();
		$port = $device['device_port'];
		$paModel = new PubAccountModel();
		$paModel->eid = $eid;
		$paModel->did = $device['id'];
		$paModel->line_name = "ngn_".$uTime;
		$paModel->port = $port;
		$paModel->devicename = $device['device_name'];
		$paModel->epname = $ep['name'];
		$paModel->device_type = $device['device_port'];
		if($province == "zhejiang")
			$paDatas['username'] = $paDatas['auth_username'] = "1116445".$paDatas['outside_callnumber'];
		elseif($province == "hebei")
			$paDatas['username'] = $paDatas['auth_username'] = "1".$paDatas['outside_callnumber'];
		else
			$paDatas['username'] = $paDatas['auth_username'] = "1".$number;
		//$paModel->username = $paModel->auth_username = "1".$number;
		$paModel->uri = DeviceModel::GetUri($paModel->username, $device["device_domain"]);
		$paModel->registrar = $paModel->proxy = DeviceModel::GetRegistar($device["device_domain"], $port);
		$paModel->realm = "*";
		$paModel->password = "123456";
		$paModel->max_in_call = $limitLine;
		$paModel->max_out_call = $limitLine;
		$paModel->max_in_out_call = $limitLine;
		$paModel->out_call_prefix = "9";
		$paModel->area_code = $numbers[0];
		$paModel->change_flag = 0;
		
		if(in_array($numbers[0],self::$INBIND_AREA) === true){
			$paModel->dtmf_type = 1;
		}else{
			$paModel->dtmf_type = 0;
		}
		$paModel->type = self::GetPubAccountType($paModel->device_type, $paModel->change_flag, $paModel->dtmf_type);
		$paModel->gw_mode = 1;//设置为regs mode
		$paModel->outside_callnumber = $numbers[1];
		$paModel->outnumber_type = $paModel->outside_type = $outType;
		
		$paModel->plan_code = $plancode;
		$paModel->call_permission = $callpermission;
		$paModel->ext_plan_code = $extPlancode;
		$paModel->province_city = StateDictModel::GetProvinceCity($numbers[0]);
		
		setEnterpriseEnvironment($eid);
		$voipCmd = new VoipCmd();
		log::write("add line in pbx");
		$result = $voipCmd->insertPubAccount($paModel->getCmdParameters());
		if($result == 0){
			//获取pbxid
			$paIds = PubAccountModel::GetPbxId($eid);
			$paModel->pbxid = $paIds[$paModel->uri];
			log::write("find line in pbx:".$paModel->pbxid);
		}
			
		return $paModel->add();
	}
	/**
	 * 保存总机号码
	 * @param unknown_type $eid
	 * @param unknown_type $uid
	 * @param unknown_type $mid
	 * @param unknown_type $paId
	 * @param unknown_type $pbxId
	 * @return boolean
	 */
	public static function SaveMemberOutnumber($eid,$uid,$mid,$paId,$pbxId){
		$mom = M("MemberOutnumber");
		$map['eid'] = $eid;
		$map['paid'] = $paId;
		$map['mid'] = $mid;
		$map['pbxid'] = $pbxId;
		$result = $mom->where($map)->find();
		if( $result == null){
			setEnterpriseEnvironment($eid);
			$voipCmd = new VoipCmd();
			$voipCmd->insertAccPub($uid, $pbxId);
			$mom->add($map);
			//log::write("SaveMemberOutnumber:".$mom->getLastSql());
			return true;
		}
		return false;
	}
	/**
	 * 查询该总机号码并设置为总机号码
	 * 不存在则设置为缺省总机号码
	 * @param unknown_type $eid
	 * @param unknown_type $uid
	 * @param unknown_type $mid
	 * @param unknown_type $number
	 * @return boolean
	 */
	public static function SetSwitchNumber($eid,$uid,$mid,$number){
		$pa = self::GetSwitchNumber($eid,$number);
		//不设置缺省总机号码
		if(empty($pa) || empty($pa['pbxid'])) return false;
		//return self::SetDefaultSwitchNumber($eid, $uid,$mid);		
		return self::SaveMemberOutnumber($eid, $uid, $mid, $pa['id'],$pa['pbxid']);
	}
	/**
	 * 设置为第一个总机号码
	 * @param unknown_type $eid
	 * @param unknown_type $uid
	 * @param unknown_type $mid
	 * @return boolean
	 */
	public static function SetDefaultSwitchNumber($eid,$uid,$mid){
		$paModel = new PubAccountModel();
		$map['eid'] = $eid;
		$map['outnumber_type'] = 0;
		$pa = $paModel->where($map)->find();
		if(empty($pa['pbxid'])) return false;
		return self::SaveMemberOutnumber($eid, $uid, $mid, $pa['id'],$pa['pbxid']);
	}
	/**
	 * 获取缺省总机号码
	 * @param unknown_type $eid
	 * @return Ambigous <mixed, boolean, NULL, multitype:>
	 */
	public static function GetDefaultSwitchNumber($eid){
		$paModel = new PubAccountModel();
		$map['eid'] = $eid;
		$paDatas = $paModel->where($map)->find();
		return $paDatas;
	}
	
	public static function DeletePubAccoutFromNumber($eid,$numbers){
		$paDatas = self::IsNumberExist($numbers);
		if($eid == $paDatas['eid'] && !empty($paDatas['pbxid'])){
			if($paDatas['outnumber_type'] == 0){
				//总机号码删除企业		
				EnterpriseModel::deleteByEid($eid);
			}else{
				//直拨号码删除号码
				self::DeletePubAccount($paDatas['id']);
                                //SyncModel::LineDelete($paDatas['id'],$eid);
			}
			return 0;
		}
		return 9;
	}
	/**
	 * 获取-t参数
	 * 根据$deviceType*4+$changeFlag*2+$dtmfType生成
	 * @param int $deviceType
	 * @param int $changeFlag
	 * @param int $dtmfType
	 * @return number
	 */
	public static function GetPubAccountType($deviceType,$changeFlag,$dtmfType){
		return $deviceType*4+$changeFlag*2+$dtmfType;
	}
	
	public static function GetPubAccountByDid($did){
		$paModel = new PubAccountModel();
		$map['did'] = $did;
		$paDatas = $paModel->where($map)->select();
		log::write($paModel->getLastSql());
		return $paDatas;
	}
	
	public static function GetProvinceCity(){
		$paModel = new PubAccountModel();
		$paDatas = $paModel->field("distinct province_city")->select();
		return $paDatas;
	}
	
	public static function GetAllForBss(){
		$paModel = new PubAccountModel();
		$result = $paModel->field("eid,outside_callnumber as outside_number,area_code
				,province_city,outnumber_type as type,call_permission,plan_code,ext_plan_code,status")->select();
		//log::write("GetSwitch:".$paModel->getLastSql());
		return $result;
	}
	
	/**
	 * 同步外线账号到运维服务器
	 * 同步失败后加入未同步用户表
	 * @param array 需同步的外线数据
	 * @return boolean 成功返回true
	 */
	public static function SyncPubaccToMaintenance($paData,$mServer=null){
		if(empty($mServer)) $mServer = ParamModel::GetMaintenanceParam();
		//没有配置单点登录服务器退出，不添加同步表
		if(empty($mServer)) return false;
		
		if(HttpConnTools::IsWgetConnected($mServer['maintenance_server']) === false){
			MaintenanceSyncModel::SaveMs("paid", $paData['id']);
			return false;
		}
		$vars['account'] = $mServer['maintenance_account'];
		$vars['password'] = $mServer['maintenance_password'];
		$vars['sid'] = $mServer['maintenance_sid'];
	
		$vars['eid'] = $paData['eid'];
		$vars['outside_number'] = $paData['outside_callnumber'];
		$vars['area_code'] = $paData['area_code'] ;
		$vars['province_city'] = $paData['province_city'] ;
		$vars['type'] = $paData['outnumber_type'] ;
		$vars['call_permission'] = $paData['call_permission'];
		$vars['plan_code'] = $paData['plan_code'] ;
		$vars['ext_plan_code'] = $paData['ext_plan_code'] ;
		$vars['status'] = $paData['status'];
		if(!empty($paData['physical_number']))
			$vars['physical_number'] = $paData['physical_number'];
		elseif(!empty($paData['username'])){
			$vars['physical_number'] = substr($paData['username'],1);
		}else{
			$vars['physical_number'] = $paData['area_code'].$paData['outside_callnumber'];
		}
		//$client->set_submit_multipart();
		$cUrl = createUrl($mServer['maintenance_server'],$mServer['maintenance_http_port']);
		$url = sprintf("%s/Api/Sync/pubacc",$cUrl);
		//echo $url;
		$retJson = HttpConnTools::HttpRequest($url, $vars);
		if(intval($retJson['status']) == 0){
			return true;
		}
		return false;
	}
	
	/**
	 * 删除外线账号到运维服务器
	 * @param array 需删除的外线数据
	 * @return boolean 成功返回true
	 */
	public static function DelPubaccToMaintenance($paData,$mServer=null){
		log::write("come here");
		if(empty($mServer)) $mServer = ParamModel::GetMaintenanceParam();
		//没有配置单点登录服务器退出，不添加同步表
		if(empty($mServer)) return false;
	
		if(HttpConnTools::IsWgetConnected($mServer['maintenance_server']) === false){
			$number = $paData['area_code'].$paData['outside_callnumber'];
			log::write("sync to maintenance fail:$number");
			MaintenanceSyncModel::SaveMs("paid", $paData['id'],1,$number);
			return false;
		}
	
		$vars['account'] = $mServer['maintenance_account'];
		$vars['password'] = $mServer['maintenance_password'];
		$vars['sid'] = $mServer['maintenance_sid'];
	
		$vars['eid'] = $paData['eid'];
		$vars['outside_number'] = $paData['outside_callnumber'];
		$vars['area_code'] = $paData['area_code'] ;
		//$client->set_submit_multipart();
		$cUrl = createUrl($mServer['maintenance_server'],$mServer['maintenance_http_port']);
		$url = sprintf("%s/Api/Sync/delPubacc",$cUrl);
		//echo $url;
		$retJson = HttpConnTools::HttpRequest($url, $vars);
		if(intval($retJson['status']) == 0){
			return true;
		}
		return false;
	}
	/**
	 * 获取直线号码对象
	 * @param unknown_type $number
	 * @return boolean|unknown
	 */
	public static function FindDirectNumber($number){
		$numbers = MobileLocation::GetAreaCode($number);
		if(count($numbers) < 2) return false;
		$paModel = new PubAccountModel();
		$map['area_code'] = $numbers[0];
		$map['outside_callnumber'] = $numbers[1];
		//$map['outside_type'] = 1;
		$map['outnumber_type'] = 1;
		$result = $paModel->where($map)->find();
		//log::write("GetSwitch:".$paModel->getLastSql());
		return $result;
	}
	/**
	 * 检查外线数据，获取运维服务器不存在的外线
	 * @param unknown_type $epDatas
	 * @return 返回不存在的外线数据
	 */
	public static function GetUnSyncPa($paDatas){
		$paModel = new PubAccountModel();
		//检查数据是否在企业服务器存在，不存在直接添加
		$paPns = array();
		foreach($paDatas as $paData){
			$number = $paData['area_code'].$paData['outside_number'];
			$paMap['outside_callnumber'] = $paData['outside_number'];
			$paMap['area_code'] = $paData['area_code'];
			$result = $paModel->where($paMap)->find();
			if(empty($result)){
				$epData = array();
				if($paData['eid'] > 0 ){
					$epData = EnterpriseModel::GetEpFromId($paData['eid']);
				}
				$paData['outside_callnumber'] = $paData['outside_number'];
				$paData['outnumber_type'] = $paData['outside_type'] = $paData['type'];
				
				if(empty($epData)){
					//只添加号码
					$paData['id'] = $paModel->add($paData);
					log::write("sync pub account success:".$number,Log::DEBUG);
				}else{
					$paData = self::AddPubAccountFromBss($epData, $paData);
					if(empty($paData)){
						log::write("sync pub account fail:".$number);
					}else{
						log::write("sync pub account success:".$number,Log::DEBUG);
					}
				}
				$paIds[] = $paData['id'];
			}else{
				$paIds[] = $result['id'];
 				log::write("check pub account already exist:".$number);
 			}
 			
		}
		if(empty($paIds)){
			$paDatas = $paModel->select();
		}else{
			$paMap = array();
			$paMap['id'] = array("not in",$paIds);
			$paDatas = $paModel->where($paMap)->select();
		}
		log::write($paModel->getLastSql());
		return $paDatas;
	}
	
	/**
	 * 绑定用户与外线号码
	 * @param unknown_type $eid
	 * @param unknown_type $mids
	 * @param unknown_type $paids
	 */
	public static function BindMemberOutnumber($eid,$mids,$paids){
		if(empty($mids) || empty($paids)) return;
		$smModel = new SipMemberModel();
		$smMap['id'] = array("in",$mids);
		$uids = $smModel->where($smMap)->getField("id,uid");
		
		$paModel = new PubAccountModel();
		$paMap['id'] = array("in",$paids);
		$pbxIds = $paModel->where($paMap)->getField("id,pbxid");
		//删除关联表
		$moModel = M("MemberOutnumber");
		$moMap['eid'] = $eid;
		$moMap['mid'] = array("in",$mids);
		$moMap['paid'] = array("in",$paids);
		$findFlag = $moModel->where($moMap)->find();
		if(!empty($findFlag)) $moModel->where($moMap)->delete();
		
		$apModel = new PbxModel($eid, "AccountPub", "r_");
		$apMap['account_id'] = array("in",$uids);
		$apMap['pub_id'] = array("in",$pbxIds);
		$findFlag = $apModel->where($apMap)->find();
		if(!empty($findFlag)) $apModel->where($apMap)->delete();
		
		$talkValues = "";$pbxValues = "";
		foreach ($uids as $mid=>$uid){
			foreach ($pbxIds as $paid=>$pbxId){
				if(!empty($talkValues)) $talkValues .= ",";
				if(!empty($pbxValues)) $pbxValues .= ",";
				$talkValues .= sprintf("(%s,%s,%s,%s)",$eid,$paid,$pbxId,$mid);
				$pbxValues  .= sprintf("(%s,%s)",$uid,$pbxId);
			}
		}
		$talkSql = "insert into talk_member_outnumber(eid,paid,pbxid,mid) values".$talkValues;
		$moModel->query($talkSql);
		log::write("insert talk outsidenumber relationship:".$moModel->getLastSql());
		$apTablename = $apModel->getTableName();
		$pbxSql = sprintf("insert into %s(account_id,pub_id) values",$apTablename).$pbxValues;
		$apModel->query($pbxSql);
		log::write("insert pbx outsidenumber relationship:".$apModel->getLastSql());
		return true;
	}
	
	/**
	 * 解除用户与外线号码的绑定关系
	 * @param unknown_type $eid
	 * @param unknown_type $mids
	 * @param unknown_type $paids
	 */
	public static function UnbindMemberOutnumber($eid,$mids,$paids){
		if(!empty($mids)){
			$smModel = new SipMemberModel();
			$smMap['id'] = array("in",$mids);
			$uids = $smModel->where($smMap)->getField("id,uid");
		}
		
		if(!empty($paids)){
			$paModel = new PubAccountModel();
			$paMap['id'] = array("in",$paids);
			$pbxIds = $paModel->where($paMap)->getField("id,pbxid");
		}
		
		//删除关联表
		$moModel = M("MemberOutnumber");
		if(!empty($eid)) $moMap['eid'] = $eid;
		if(!empty($mids)) $moMap['mid'] = array("in",$mids);
		if(!empty($paids)) $moMap['paid'] = array("in",$paids);
		if(!empty($moMap)){
			$findFlag = $moModel->where($moMap)->find();
			if(!empty($findFlag)) $moModel->where($moMap)->delete();
			log::write("delete talk outsidenumber relationship:".$moModel->getLastSql());
		}
		
		$apModel = new PbxModel($eid, "AccountPub", "r_");
		if(!empty($uids)) $apMap['account_id'] = array("in",$uids);
		if(!empty($pbxIds)) $apMap['pub_id'] = array("in",$pbxIds);
		if(!empty($apMap)){
			$findFlag = $apModel->where($apMap)->find();
			if(!empty($findFlag)) $apModel->where($apMap)->delete();
			log::write("delete pbx outsidenumber relationship:".$apModel->getLastSql());
		}
	}
	
	/**
	 * 获取部门外线id
	 * @param unknown_type $gid
	 * @return array paid数组
	 */
	public static function GetDeptOutnumber($gid){
		$ret = array();
		$doModel = M("DeptOutnumber");
		if(is_array($gid)) $doMap['gid'] = array("in",$gid); else $doMap['gid'] = $gid;
		$ret = $doModel->where($doMap)->getField("id,paid");
		return $ret;
	}
	
	/**
	 * 设置或删除部门外线关联
	 * @param unknown_type $gid
	 * @param unknown_type $paids
	 */
	public static function SetDeptOutnumber($gid,$paids = NULL){
		//删除部门外线id
		$doModel = M("DeptOutnumber");
		$doData['gid'] = $gid;
		$ret = $doModel->where($doData)->delete();
		//设置部门外线
		if(!empty($paids)){
			foreach ($paids as $paid){
				$doData['paid'] = $paid;
				$doModel->add($doData);
			}
		}
		log::write("delete relationship of dept and outnumber:".$doModel->getLastSql(),Log::DEBUG);
	}
	
	/**
	 * 根据外线id删除企业外线
	 * @param unknown_type $paid
	 * @return unknown
	 */
	public static function removeDeptOutnumberByPaid($paid){
		//删除部门外线id
		$doModel = M("DeptOutnumber");
		$doMap['paid'] = $paid;
		$ret = $doModel->where($doMap)->delete();
		log::write("delete dept outnumber:".$doModel->getLastSql());
		return $ret;
	}
	
	/**
	 * 获取外线数组
	 * @param int $eid
	 * @param int $type
	 * @return array
	 */
	public static function GetOutlines($eid,$type=null){
		if(empty($eid)) return array();
		$paModel = new PubAccountModel();
		$field = "area_code,outside_callnumber,call_permission,status,pstn_teleconf_type,pstn_teleconf_max";
		$paMap['eid'] = $eid;
		if(!empty($type)) $paMap["outnumber_type"] = $type;
		$retDatas = $paModel->where($paMap)->select();
		return $retDatas;
	}
	/**
	 * 获取会议号码类型数组
	 * @param int $eid
	 * @return array
	 */
	public static function GetOutlinePstntype($eid){
		if(empty($eid)) return array();
		$paModel = new PubAccountModel();
		$paMap['eid'] = $eid;
		$paMap['outnumber_type'] = 2;
		$retDatas = $paModel->where($paMap)->group("pstn_teleconf_type")->getField("id,pstn_teleconf_type");
		return $retDatas?array_values($retDatas):array();
	}
	
	/**
	 * 获取直线号码个数
	 * @param unknown $eid
	 * @return boolean|unknown
	 */
	public static function SumDirectNumberCount($eid){
		if(empty($eid)) return false;
		$paModel = new PubAccountModel();
		$paMap['eid'] = $eid;
		$paMap['outnumber_type'] = 1;
		$count = $paModel->where($paMap)->count();
		return $count;
	}
	/**
	 * 修改外线数据
	 * @param  $paVals 待修改的参数
	 * @return boolean 修改结果true成功false失败
	 */
	public static function SaveData($paVals){
		if(empty($paVals['id']) || empty($paVals['eid']) || empty($paVals['pbxid'])) return false;
		$paModel = new PubAccountModel();
		$paModel->where("id=".$paVals['id'])->save($paVals);		
		//通知sip服务器		
		setEnterpriseEnvironment($paVals['eid']);
		$voipCmd = new VoipCmd();
		$paVal['pbxid'] = $paDatas['pbxid'];
		$flag = $voipCmd->modifyPubAccount($paModel->getCmdParametersFromDatas($paVals));
		log::write("修改外线状态为:".$paVals['status']."--修改状态:".$flag,log::DEBUG);
		return $flag;
	}

    /**
     * 根据id获取总机信息
     * @param $eid
     * @return 总机信息
     */
    public static function GetPubAccountById($ids=array()){
        $paModel = new PubAccountModel();
        if(!empty($ids)){
            $map['id'] = array("in",$ids);
        }
        return $paModel->where($map)->order("id asc")->select();
    }
    public static function GetPubAccountByEid($eid){
        $paModel = new PubAccountModel();
        if(!empty($eid)){
            $map['eid'] = $eid;
        }
        return $paModel->where($map)->order("id asc")->select();
    }
    public static function CheckPubAccount($paid,$eid){
        $paModel = new PubAccountModel();
        $paMap['id']= $paid;
        $paMap['eid']= $eid;
        return $paModel->where($paMap)->find();
    }
    /** 
     * 获取企业的外线信息
     * @param type $eid
     * @return type
     */
    public static function GetAllPubAccountInfo($eid) {
        $paModel = new PubAccountModel();
        $map['eid'] = $eid;
        $data = $paModel->where($map)->select();
        return $data;
    }
}
?>
