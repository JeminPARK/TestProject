<%@page import="evaluation.EvaluationDAO"%>
<%@page import="evaluation.EvaluationDTO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="user.UserDAO"%>
<%@page import="java.io.PrintWriter"%>
<%@page import="java.net.URLEncoder"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no" >
<title>강의평가 웹사이트</title>
<!--  부트스트랩 css 추가하기 -->
<link rel="stylesheet" href="./css/bootstrap.min.css">
<!--  커스텀 CSS 추가하기 -->
<link rel="stylesheet" href="./css/custom.css">
</head>

<body>

<%

	request.setCharacterEncoding("UTF-8");
	String lectureDivide = "전체";
	String searchType = "최신순";
	String search = "";
	int pageNumber = 0;
	if(request.getParameter("lectureDivide") != null){
		lectureDivide = request.getParameter("lectureDivide");
	}
	if(request.getParameter("searchType") != null){
		searchType = request.getParameter("searchType");
	}
	if(request.getParameter("search") != null){
		search = request.getParameter("search");
	}
	if(request.getParameter("pageNumber") != null){
		try{
		pageNumber = Integer.parseInt(request.getParameter("search"));
			
		}
		catch(Exception e){
			e.printStackTrace();
			System.out.println("검색페이지 번호 오류");
		}
	}
	
	String userID = null;
	System.out.println("userID: "+userID);
	if(session.getAttribute("userID") != null){
		userID = (String) session.getAttribute("userID");
	}
	if(userID == null){
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('로그인을 해주세요.')");
		script.println("location.href = 'userLogin.jsp';");
		script.println("</script>");
		script.close();
		return;
		
	}
	//이메일 인증 이 안되있을시 강의평가를 할수 없게 해야함.
	boolean emailChecked = new UserDAO().getUserEmailChecked(userID);
	if(emailChecked == false){
		PrintWriter script = response.getWriter();
		script.println("<script>");		
		script.println("location.href = 'emailSendConfirm.jsp';");
		script.println("</script>");
		script.close();
		return;
	}
	
%>
<nav class = "navbar navbar-expand-lg navbar-light bg-light" aria-label="First navbar example">

        <div class = "container-fluid">
            <a class ="navbar-brand" href="index.jsp">강의평가 웹사이트</a>
            <button class ="navbar-toggler collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#navbarsExample01" aria-controls=""navbarsExample01
            aria-expanded="false" aria-label="Toggle navigation">
                <span class = "navbar-toggler-icon"></span>
            </button>
            <div class ="navbar-collapse collapse" id ="navbarsExample01" style>
                <ul class ="navbar-nav me-auto mb-2">
                    <li class ="nav-item">
                        <a class = "nav-link active" aria-current="page" href="index.jsp">메인</a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class = "nav-link dropdown-toggle" href="#" id="dropdown01" data-bs-toggle="dropdown" aria-expanded="false">회원관리</a>
                        <ul class="dropdown-menu" aria-labelledby="dropdown01">
                        
                        <%
                        	if(userID == null){
                        		
                        	
                        %>
                            <li>
                                <a class="dropdown-item" href="userLogin.jsp">로그인</a>
                            </li>
                            <li>
                                <a class="dropdown-item" href="userJoin.jsp">회원가입</a>
                            </li>
                            
                         <%
                        	}else{
                         %>
                            <li>
                                <a class="dropdown-item" href="userLogout.jsp">로그아웃</a>
                            </li>
						<% 
							} 
						
						%>
                        </ul>
                    </li>

                </ul>
                <form action= "./index.jsp" method = "get" class="d-flex">
                    <input class="form-control me-2" type="text" placeholder="내용을 입력하세요." aria-label="Search" name = "search">
                    <button class ="btn btn-outline-success" style="white-space:nowrap;" type="submit">검색</button>
                </form>

            </div>
        </div>		
	</nav>
	<section class = "container">
		<form method="get" action="./index.jsp" class = "form-inline mt-3">
			<select name="lectureDivide" class = "form-control-sm mx-1 mt-2">
				<option value="전체">전체</option>
				<option value="전공" <% if(lectureDivide.equals("전공")) out.println("selected"); %>>전공</option>
				<option value="교양" <% if(lectureDivide.equals("교양")) out.println("selected"); %>>교양</option>
				<option value="기타" <% if(lectureDivide.equals("기타")) out.println("selected"); %>>기타</option>
				
			</select>
			<select name="searchType" class = "form-control-sm mx-1 mt-2">
				<option value="최신순">최신순</option>
				<option value="추천순" <% if(searchType.equals("추천순")) out.println("selected"); %>>추천순</option>
								
			</select>
			<input type="text" name="search" class="form-control mx-1 mt-2" placeholder ="내용을 입력하세요">
			<button type="submit" class="btn btn-primary mx-1 mt-2">검색</button>
			<a class="btn btn-primary mx-1 mt-2" data-bs-toggle="modal" href="#registerModal">등록하기</a>
			<a class= "btn btn-danger mx-1 mt-2 " data-bs-toggle="modal" href="#reportModal">신고</a>
		</form>
<%
	ArrayList<EvaluationDTO> evaluationList = new ArrayList<>();
	evaluationList = new EvaluationDAO().getList(lectureDivide, searchType, search, pageNumber);
	if(evaluationList != null)
		for(int i=0; i<evaluationList.size(); i++){
			
			if(i == 5) break;
			
			EvaluationDTO evaluation = evaluationList.get(i);
		
	

%>
        <div class = "card bg-light mt-3 ms-1">
            <div class = "card-header bg-light">
                <div class = "row">
                    <div class = "col-8 text-start"><%=evaluation.getLectureName() %>&nbsp;<small><%= evaluation.getProfessorName() %></small></div>
                    <div class = "col-4 text-end">
                        <span style="color:red;"><%= evaluation.getTotalScore() %></span>
                    </div>
                </div>
            </div>
            <div class = "card-body">
                <h5 class = "card-title">
                    <%=evaluation.getEvaluationTitle() %> &nbsp;<small>(<%= evaluation.getLectureYear() %>) 년 (<%=evaluation.getSemesterDivide() %>)</small>
                </h5>
                <p class = "card-text"><%=evaluation.getEvaluationContent() %></p>
                <div class = "row">
                    <div class = "col-9 text-start">
                        성적<span style = "color: red;"><%=evaluation.getCreditScore() %></span>
                        널널<span style = "color: red;"><%=evaluation.getComfortableScore() %></span>
                        강의<span style = "color: red;"><%=evaluation.getLectureScore() %></span>
                        <span style = "color: green;">(추천: <%=evaluation.getLikeCount() %>)</span>
                    </div>
                    <div class = "col-3 text-end">
                        <a onclick ="return confirm('추천 하시겠습니까?')" href="./likeAction.jsp?evaluationID=<%=evaluation.getEvaluationID() %>">추천</a>
                        <a onclick ="return confirm('삭제 하시겠습니까?')" href="./deleteAction.jsp?evaluationID=<%=evaluation.getEvaluationID() %>">삭제</a>
                    </div>
                </div>
            </div>

        </div>

       <!--  <div class = "card bg-light mt-3 ms-1">
            <div class = "card-header bg-light">
                <div class = "row">
                    <div class = "col-8 text-start">컴퓨터그래픽스&nbsp;<small>김출력</small></div>
                    <div class = "col-4 text-end">종합
                        <span style="color:red;">A</span>
                    </div>
                </div>
            </div>
            <div class = "card-body">
                <h5 class = "card-title">
                    나쁘지 않은 것 같습니다. &nbsp;<small>(2021년 여름학기)</small>
                </h5>
                <p class = "card-text">컴퓨터 그래픽스를 처음 배웠는데, 상당히 재미있었던 것같아요 </p>
                <div class = "row">
                    <div class = "col-9 text-start">
                        성적<span style = "color: red;">A</span>
                        널널<span style = "color: red;">A</span>
                        강의<span style = "color: red;">B</span>
                        <span style = "color: green;">(추천: 15)</span>
                    </div>
                    <div class = "col-3 text-end">
                        <a onclick ="return confirm('추천 하시겠습니까?')" href="./likeAction.jsp?evaluationID=">추천</a>
                        <a onclick ="return confirm('삭제 하시겠습니까?')" href="./deleteAction.jsp?evaluationID=">삭제</a>
                    </div>
                </div>
            </div>

        </div>
        <div class = "card bg-light mt-3 ms-1">
            <div class = "card-header bg-light">
                <div class = "row">
                    <div class = "col-8 text-start">컴퓨터개론&nbsp;<small>전산원</small></div>
                    <div class = "col-4 text-end">종합
                        <span style="color:red;">B</span>
                    </div>
                </div>
            </div>
            <div class = "card-body">
                <h5 class = "card-title">
                    강의력이 제일 좋은 강의입니다. &nbsp;<small>(2021년 2학기)</small>
                </h5>
                <p class = "card-text">알고리즘 강의 가르치시는 교수님들 중에서 최고로 잘 가르치십니다.</p>
                <div class = "row">
                    <div class = "col-9 text-start">
                        성적<span style = "color: red;">A</span>
                        널널<span style = "color: red;">A</span>
                        강의<span style = "color: red;">B</span>
                        <span style = "color: green;">(추천: 13)</span>
                    </div>
                    <div class = "col-3 text-end">
                        <a onclick ="return confirm('추천 하시겠습니까?')" href="./likeAction.jsp?evaluationID=">추천</a>
                        <a onclick ="return confirm('삭제 하시겠습니까?')" href="./deleteAction.jsp?evaluationID=">삭제</a>
                    </div>
                </div>
            </div>

        </div> -->
<%
		
	}
%>		
	</section>
    <ul class = "pagination justify-content-center mt-3">
    	<li class = "page-item">
<%
	if(pageNumber <= 0){	
%>
	<a class = "page-link disabled">이전</a>
<%
	}
	else{
%>
	<a class = "page-link" href = "./index.jsp?lectureDivide=<%=URLEncoder.encode(lectureDivide, "UTF-8")%>&searchType=
									<%=URLEncoder.encode(searchType, "UTF-8") %>&search=
									<%=URLEncoder.encode(search, "UTF-8") %>&pageNumber=
									<%=pageNumber -1 %>">이전</a>
		
<%
	}
%>		
		</li>
	    <li class = "page-item">
<%
	System.out.println("강의평가갯수: "+evaluationList.size());
	if(evaluationList.size() < 6){	
%>
	<a class = "page-link disabled">다음</a>
<%
	}
	else{
%>
	<a class = "page-link" href = "./index.jsp?lectureDivide=<%=URLEncoder.encode(lectureDivide, "UTF-8") %>&searchType=
									<%=URLEncoder.encode(searchType, "UTF-8") %>&search=
									<%=URLEncoder.encode(search, "UTF-8") %>&pageNumber=
									<%=pageNumber + 1 %>">다음</a>
		
<%
	}

%>		
		</li>
    	
    </ul>
	<div class="modal fade" id ="registerModal" tabindex="-1" role="dialog" aria-labelledby ="modal" aria-hidden ="true">
		<div class = "modal-dialog">
			<div class="modal-content">
				<div class = "modal-header">
					<h5 class = "modal-title" id="modal">평가등록</h5>
					<button type = "button" class = "close" data-bs-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
				</div>
				<div class = "modal-body">
                    <form action ="./evaluationRegisterAction.jsp" method = "post">
                        <div class = "form-row">
                            <div class="form-group col-sm-6">
                                <label>강의명</label>
                                <input type ="text" name ="lectureName" class="form-control" maxlength="20">
                            </div>
                            <div class="form-group col-sm-6">
                                <label>교수명</label>
                                <input type ="text" name ="professorName" class="form-control" maxlength="20">
                            </div>

                        </div>
                        <div class = "form-row d-flex justify-content-around">
                           <div class = "form-group col-sm-4">
                               <label>수강 연도</label>
                               <select name="lectureYear" class ="form-control">
                                <option value="2011">2011</option>
                                <option value="2012">2012</option>
                                <option value="2013">2013</option>
                                <option value="2014">2014</option>
                                <option value="2015">2015</option>
                                <option value="2016">2016</option>
                                <option value="2017">2017</option>
                                <option value="2018">2018</option>
                                <option value="2019">2019</option>
                                <option value="2020">2020</option>
                                <option value="2021">2021</option>
                                <option value="2022" selected>2022</option>
                                <option value="2023">2023</option>
                                <option value="2024">2024</option>
                                <option value="2025">2025</option>

                               </select>
                           </div>
                           <div class="form-group col-sm-4">
                               <label>수강 학기</label>
                               <select name="semesterDivide" class = "form-control">
                                    <option value = "1학기" selected>1학기</option> 
                                    <option value = "여름학기">여름학기</option> 
                                    <option value = "2학기" >2학기</option> 
                                    <option value = "겨울학기">겨울학기</option>                                     
                            
                               </select>
                           </div> 
                           <div class="form-group col-sm-4">
                            <label>강의 구분</label>
                            <select name="lectureDivide" class = "form-control">
                                 <option value = "전공" selected>전공</option> 
                                 <option value = "교양" >교양</option> 
                                 <option value = "기타" >기타</option> 
                                                                  
                         
                            </select>
                        </div> 

                        </div>
                        <div class=" form-group">
                            <label>제목</label>
                            <input type="text" name = "evaluationTitle" class = "form-control" maxlength="30">
                        </div>
                        <div class = "form-group">
                            <label>내용</label>
                            <textarea name="evaluationContent" class = "form-control" maxlength="2048" style="height: 180px; resize:none;"></textarea>
                        </div>
                        <div class = "form-row d-flex justify-content-around">
                            <div class = "form-group col-sm-3">
                                <label>종합</label>
                                <select name="totalScore" class ="form-control">
                                    <option value ="A" selected>A</option>
                                    <option value ="B" >B</option>
                                    <option value ="C" >C</option>
                                    <option value ="D" >D</option>
                                    <option value ="F" >F</option>
                                </select>
                            </div>
                            <div class = "form-group col-sm-3">
                                <label>성적</label>
                                <select name="creditScore" class ="form-control">
                                    <option value ="A" selected>A</option>
                                    <option value ="B" >B</option>
                                    <option value ="C" >C</option>
                                    <option value ="D" >D</option>
                                    <option value ="F" >F</option>
                                </select>
                            </div>
                            <div class = "form-group col-sm-3">
                                <label>널널</label>
                                <select name="comfortableScore" class ="form-control">
                                    <option value ="A" selected>A</option>
                                    <option value ="B" >B</option>
                                    <option value ="C" >C</option>
                                    <option value ="D" >D</option>
                                    <option value ="F" >F</option>
                                </select>
                            </div>
                            <div class = "form-group col-sm-3">
                                <label>강의</label>
                                <select name="lectureScore" class ="form-control">
                                    <option value ="A" selected>A</option>
                                    <option value ="B" >B</option>
                                    <option value ="C" >C</option>
                                    <option value ="D" >D</option>
                                    <option value ="F" >F</option>
                                </select>
                            </div>
                        </div>
                        <div class = "modal-footer">
                            <button type ="button" class= "btn btn-secondary" data-bs-dismiss="modal">취소</button>
                            <button type = "submit" class = "btn btn-primary">등록</button>
                        </div>
                    </form>
				</div>
			</div>
		</div>
	</div>
    <div class="modal fade" id ="reportModal" tabindex="-1" role="dialog" aria-labelledby ="modal" aria-hidden ="true">
		<div class = "modal-dialog">
			<div class="modal-content">
				<div class = "modal-header">
					<h5 class = "modal-title" id="modal">신고하기</h5>
					<button type = "button" class = "close" data-bs-dismiss="modal" aria-label="Close">
						<span aria-hidden="true">&times;</span>
					</button>
				</div>
				<div class = "modal-body">
                    <form action ="./reportAction.jsp" method = "post">
                       
                        <div class=" form-group">
                            <label>신고 제목</label>
                            <input type="text" name = "reportTitle" class = "form-control" maxlength="30">
                        </div>
                        <div class = "form-group">
                            <label>신고 내용</label>
                            <textarea name="reportContent" class = "form-control" maxlength="2048" style="height: 180px; resize:none;"></textarea>
                        </div>                        
                        <div class = "modal-footer">
                            <button type ="button" class= "btn btn-secondary" data-bs-dismiss="modal">취소</button>
                            <button type = "submit" class = "btn btn-danger">신고하기</button>
                        </div>
                    </form>
				</div>
			</div>
		</div>
	</div>
    <footer class = "bg-dark mt-4 p-5 text-center" style = "color: #ffffff;">
        Copyright &copy; 2021 박제민 All Rights Reserved.
    </footer>
	
	<!-- 제이쿼리 자바스크립트 추가하기 -->
	<script src = "./js/jquery.min.js"></script>
	<!-- 파퍼js 추가하기 -->
	<script src = "./js/pooper.js"></script>
	<!-- 부트스트랩 자바스크립트 추가하기 -->
	<script src = "./js/bootstrap.min.js"></script>
</body>
</html>