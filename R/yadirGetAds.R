yadirGetAds <- function(CampaignIds   = NULL, 
                        AdGroupIds    = NA, 
                        Ids           = NA, 
                        States        = c("OFF","ON","SUSPENDED","OFF_BY_MONITORING","ARCHIVED"), 
                        Login         = NULL,
                        Token         = NULL,
                        AgencyAccount = NULL,
                        TokenPath     = getwd()){
  
  #�����������
  Token <- tech_auth(login = Login, token = Token, AgencyAccount = AgencyAccount, TokenPath = TokenPath)

  #��������� ���� �� ����� ������ ��������� �������� ��������� ��� � �������� ��� ������
  if (is.null(CampaignIds)) {
    CampaignIds <-  yadirGetCampaignList(Login         = Login,
                                         AgencyAccount = AgencyAccount,
                                         Token         = Token,
                                         TokenPath     = TokenPath)$Id
  }
#��������� ����� ������ ������
start_time  <- Sys.time()

#�������������� ���� �����
result      <- data.frame(Id                  = integer(0), 
                          AdGroupId           = integer(0),
                          CampaignId          = integer(0),
                          Type                = character(0),
                          Subtype             = character(0),
                          Status              = character(0),
                          AgeLabel            = character(0),
                          State               = character(0),
                          TextAdTitle         = character(0),
                          TextAdTitle2        = character(0),
                          TextAdText          = character(0),
                          TextAdHref          = character(0),
                          TextAdDisplayDomain = character(0),
                          TextAdMobile        = character(0),
                          TextImageAdHref     = character(0))

#��������� ������ �� ������� � json
States          <- paste("\"",States,"\"",collapse=", ",sep="")

#���������� ���������� �������� ������� ��������� ����������
camp_num     <- as.integer(length(CampaignIds))
camp_start   <- 1
camp_step    <- 10

packageStartupMessage("Processing", appendLF = F)
#��������� ���� ��������� ��������
while(camp_start <= camp_num){

#���������� ����� �-�� �� ���� ����������
camp_step   <-  if(camp_num - camp_start >= 10) camp_step else camp_num - camp_start + 1

#����������� ������ ��������� ��������
Ids             <- ifelse(is.na(Ids), NA,paste0(Ids, collapse = ","))
AdGroupIds      <- ifelse(is.na(AdGroupIds),NA,paste0(AdGroupIds, collapse = ","))
CampaignIdsTmp  <- paste("\"",CampaignIds[camp_start:(camp_start + camp_step - 1)],"\"",collapse=", ",sep="")

#����� ��������� offset
lim <- 0

while(lim != "stoped"){
  
  queryBody <- paste0("{
  \"method\": \"get\",
                      \"params\": {
                      \"SelectionCriteria\": {
                      \"CampaignIds\": [",CampaignIdsTmp,"],
                      ",ifelse(is.na(Ids),"",paste0("\"Ids\": [",Ids,"],")),"        
                      ",ifelse(is.na(AdGroupIds),"",paste0("\"AdGroupIds\": [",AdGroupIds,"],")),"
                      \"States\": [",States,"]
},
                      
                      \"FieldNames\": [
                      \"Id\",
                      \"CampaignId\",
                      \"AdGroupId\",
                      \"Status\",
                      \"State\",
                      \"AgeLabel\",
                      \"Type\",
                      \"Subtype\"],
                      \"TextAdFieldNames\": [
                      \"Title\",
                      \"Title2\",
                      \"Text\",
                      \"Href\",
                      \"Mobile\",
                      \"DisplayDomain\"],
                      \"TextImageAdFieldNames\": [
                      \"Href\"],
                      \"Page\": {  
                      \"Limit\": 10000,
                      \"Offset\": ",lim,"}
}
}")

  answer <- POST("https://api.direct.yandex.com/json/v5/ads", body = queryBody, add_headers(Authorization = paste0("Bearer ",Token), 'Accept-Language' = "ru",'Client-Login' = Login))
  stop_for_status(answer)
  dataRaw <- content(answer, "parsed", "application/json")
  
  #�������� �� ������ �� ������ ������
  if(length(dataRaw$error) > 0){
    stop(paste0(dataRaw$error$error_string, " - ", dataRaw$error$error_detail))
  }
  
#������ ������
  for(ads_i in 1:length(dataRaw$result$Ads)){
      result      <- rbind(result,
                           data.frame(Id                  = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$Id), NA,dataRaw$result$Ads[[ads_i]]$Id), 
                                      AdGroupId           = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$AdGroupId), NA,dataRaw$result$Ads[[ads_i]]$AdGroupId),
                                      CampaignId          = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$CampaignId), NA,dataRaw$result$Ads[[ads_i]]$CampaignId),
                                      Type                = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$Type), NA,dataRaw$result$Ads[[ads_i]]$Type),
                                      Subtype             = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$Subtype), NA,dataRaw$result$Ads[[ads_i]]$Subtype),
                                      Status              = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$Status), NA,dataRaw$result$Ads[[ads_i]]$Status),
                                      AgeLabel            = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$AgeLabel), NA,dataRaw$result$Ads[[ads_i]]$AgeLabel),
                                      State               = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$State), NA,dataRaw$result$Ads[[ads_i]]$State),
                                      TextAdTitle         = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$TextAd$Title), NA,dataRaw$result$Ads[[ads_i]]$TextAd$Title),
                                      TextAdTitle2        = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$TextAd$Title2), NA,dataRaw$result$Ads[[ads_i]]$TextAd$Title2),
                                      TextAdText          = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$TextAd$Text), NA,dataRaw$result$Ads[[ads_i]]$TextAd$Text),
                                      TextAdHref          = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$TextAd$Href), NA,dataRaw$result$Ads[[ads_i]]$TextAd$Href),
                                      TextAdDisplayDomain = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$TextAd$DisplayDomain), NA,dataRaw$result$Ads[[ads_i]]$TextAd$DisplayDomain),
                                      TextAdMobile        = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$TextAd$Mobile), NA,dataRaw$result$Ads[[ads_i]]$TextAd$Mobile),
                                      TextImageAdHref     = ifelse(is.null(dataRaw$result$Ads[[ads_i]]$TextImageAd$Href), NA,dataRaw$result$Ads[[ads_i]]$TextImageAd$Href)))
}
#��������� �����, ��� ������� �������� ���
  packageStartupMessage(".", appendLF = F)
#��������� �������� �� ��� ������ ������� ���� �������
 lim <- ifelse(is.null(dataRaw$result$LimitedBy), "stoped",dataRaw$result$LimitedBy + 1)
}

#���������� ��������� ��� ��������
camp_start <- camp_start + camp_step
}

#��������� ����� ���������� ���������
stop_time <- Sys.time()

#��������� � ���, ��� �������� ������ ������ �������
packageStartupMessage("Done", appendLF = T)
packageStartupMessage(paste0("���������� ���������� ����������: ", nrow(result)), appendLF = T)
packageStartupMessage(paste0("������������ ������: ", round(difftime(stop_time, start_time , units ="secs"),0), " ���."), appendLF = T)
#���������� ���������
return(result)}
